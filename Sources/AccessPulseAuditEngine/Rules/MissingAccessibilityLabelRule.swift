import AccessPulseCore
import Foundation

public struct MissingAccessibilityLabelRule: AccessibilityRule {
    public let id = "missing_accessibility_label"
    public let name = "Missing Accessibility Label"

    public init() {}

    public func audit(in context: AuditContext) async -> [AccessibilityFinding] {
        var findings: [AccessibilityFinding] = []

        for file in context.files {
            let lines = RuleHelpers.lines(for: file.content)

            for index in lines.indices {
                let line = lines[index]
                let nearbyLines = lines[index...min(index + 3, lines.count - 1)].joined(separator: "\n")
                let priorLines = lines[max(0, index - 2)...index].joined(separator: "\n")
                let isDecorativeImage = line.contains("Label(") || line.contains("AccessibleButton(")
                let isInsideImageOnlyButton = priorLines.contains("Button(action:")

                if line.contains("Image(systemName:"),
                   !nearbyLines.contains(".accessibilityLabel("),
                   !isDecorativeImage,
                   !isInsideImageOnlyButton {
                    findings.append(makeFinding(filePath: file.path, line: index + 1))
                    continue
                }

                if line.contains("Button(action:"),
                   nearbyLines.contains("Image(systemName:"),
                   !nearbyLines.contains(".accessibilityLabel(") {
                    findings.append(makeFinding(filePath: file.path, line: index + 1))
                }
            }
        }

        return findings
    }

    private func makeFinding(filePath: String, line: Int) -> AccessibilityFinding {
        AccessibilityFinding(
            ruleID: id,
            summary: "Potential missing accessibility label",
            detail: "A common control pattern was found without a nearby explicit accessibility label.",
            severity: .warning,
            remediation: "Add `.accessibilityLabel(...)` or provide a descriptive text label that VoiceOver can announce clearly.",
            location: AccessibilityLocation(filePath: filePath, line: line),
            tags: ["voiceover", "label", "swiftui"]
        )
    }
}
