import AccessPulseCore
import Foundation
import SwiftSyntax

final class PlaceholderOnlyTextFieldVisitor: SyntaxVisitor {
    private let filePath: String
    private let converter: SourceLocationConverter
    private(set) var findings: [AccessibilityFinding] = []

    init(filePath: String, tree: SourceFileSyntax) {
        self.filePath = filePath
        self.converter = SourceLocationConverter(fileName: filePath, tree: tree)
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        guard let calledExpression = node.calledExpression.as(DeclReferenceExprSyntax.self),
              calledExpression.baseName.text == "TextField",
              let firstArgument = node.arguments.first?.expression.as(StringLiteralExprSyntax.self) else {
            return .visitChildren
        }

        let title = firstArgument.segments
            .compactMap { $0.as(StringSegmentSyntax.self)?.content.text }
            .joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard title.isEmpty,
              !AccessibilitySyntaxHelpers.hasAncestorModifier(named: "accessibilityLabel", near: node) else {
            return .visitChildren
        }

        let location = converter.location(for: node.positionAfterSkippingLeadingTrivia)
        findings.append(
            AccessibilityFinding(
                ruleID: "placeholder_only_textfield",
                summary: "TextField relies on placeholder text alone",
                detail: "Fields with an empty title are often unclear for VoiceOver and can lose context once text entry begins.",
                severity: .warning,
                remediation: "Provide a visible label or add `.accessibilityLabel(...)` so the field has a stable accessible name.",
                location: AccessibilityLocation(
                    filePath: filePath,
                    line: location.line,
                    column: location.column
                ),
                tags: ["swift-syntax", "forms", "voiceover"]
            )
        )

        return .visitChildren
    }
}
