import AccessPulseCore
import Foundation

public struct AccessibilityHiddenInteractiveRule: AccessibilityRule {
    public let id = "interactive_element_hidden_from_accessibility"
    public let name = "Interactive Element Hidden From Accessibility"

    public init() {}

    public func audit(in context: AuditContext) async -> [AccessibilityFinding] {
        var findings: [AccessibilityFinding] = []

        for file in context.files {
            if file.path.contains("/AccessPulseAuditEngine/Rules/") {
                continue
            }

            let lines = RuleHelpers.lines(for: file.content)

            for index in lines.indices {
                let line = lines[index].trimmingCharacters(in: .whitespaces)
                let nearbyLines = Array(lines[index...min(index + 3, lines.count - 1)])
                let looksInteractive = line.contains("Button(") || line.contains("Toggle(") || line.contains("NavigationLink(")
                let isLikelyCodeLine = !line.contains("\"Button(\"") && !line.contains("\"Toggle(\"") && !line.contains("\"NavigationLink(\"")
                let hidesInteractiveElement = nearbyLines.dropFirst().contains { $0.contains(".accessibilityHidden(true)") }

                if looksInteractive, isLikelyCodeLine, hidesInteractiveElement {
                    findings.append(
                        AccessibilityFinding(
                            ruleID: id,
                            summary: "Interactive element is hidden from assistive technologies",
                            detail: "Hiding a tappable control from the accessibility tree can make the UI unusable for VoiceOver users.",
                            severity: .error,
                            remediation: "Remove `.accessibilityHidden(true)` from interactive controls unless a fully equivalent accessible control is provided elsewhere.",
                            location: AccessibilityLocation(filePath: file.path, line: index + 1),
                            tags: ["voiceover", "focus", "swiftui"]
                        )
                    )
                }
            }
        }

        return findings
    }
}
