import AccessPulseCore
import SwiftSyntax

final class IconOnlyButtonVisitor: SyntaxVisitor {
    private let filePath: String
    private let converter: SourceLocationConverter
    private(set) var findings: [AccessibilityFinding] = []

    init(filePath: String, tree: SourceFileSyntax) {
        self.filePath = filePath
        self.converter = SourceLocationConverter(fileName: filePath, tree: tree)
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        guard AccessibilitySyntaxHelpers.calledName(for: node) == "Button",
              !hasTextLabel(node),
              isImageOnlyButton(node),
              !AccessibilitySyntaxHelpers.hasAncestorModifier(named: "accessibilityLabel", near: node) else {
            return .visitChildren
        }

        let location = converter.location(for: node.positionAfterSkippingLeadingTrivia)
        findings.append(
            AccessibilityFinding(
                ruleID: "missing_accessibility_label",
                summary: "Potential missing accessibility label",
                detail: "An icon-only button was found without a nearby explicit accessibility label.",
                severity: .warning,
                remediation: "Add `.accessibilityLabel(...)` or use a text-based `Button` label so VoiceOver can announce the action clearly.",
                location: AccessibilityLocation(
                    filePath: filePath,
                    line: location.line,
                    column: location.column
                ),
                tags: ["voiceover", "label", "swift-syntax", "button"]
            )
        )

        return .visitChildren
    }

    private func hasTextLabel(_ node: FunctionCallExprSyntax) -> Bool {
        for argument in node.arguments {
            if let literal = argument.expression.as(StringLiteralExprSyntax.self) {
                let title = literal.segments
                    .compactMap { $0.as(StringSegmentSyntax.self)?.content.text }
                    .joined()
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                if !title.isEmpty {
                    return true
                }
            }
        }

        let labelText = node.trailingClosure?.statements.description ?? ""
        return labelText.contains("Text(") || labelText.contains("Label(")
    }

    private func isImageOnlyButton(_ node: FunctionCallExprSyntax) -> Bool {
        let nodeText = node.description
        if nodeText.contains("Image(") && !nodeText.contains("Text(") && !nodeText.contains("Label(") {
            return true
        }

        let closureText = node.trailingClosure?.statements.description ?? ""
        if closureText.contains("Image(") && !closureText.contains("Text(") && !closureText.contains("Label(") {
            return true
        }

        let additionalClosureText = node.additionalTrailingClosures.description
        return additionalClosureText.contains("Image(")
            && !additionalClosureText.contains("Text(")
            && !additionalClosureText.contains("Label(")
    }
}
