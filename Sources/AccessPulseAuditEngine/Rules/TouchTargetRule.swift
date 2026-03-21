import AccessPulseCore
import Foundation

public struct TouchTargetRule: AccessibilityRule {
    public let id = "small_touch_target"
    public let name = "Small Touch Target"

    public init() {}

    public func audit(in context: AuditContext) async -> [AccessibilityFinding] {
        var findings: [AccessibilityFinding] = []
        let pattern = #"\.frame\s*\(\s*(?:minWidth|width):\s*(\d+)(?:,\s*(?:minHeight|height):\s*(\d+))?"#

        for file in context.files {
            let matches = RuleHelpers.regexMatches(pattern: pattern, in: file.content)
            for match in matches {
                guard match.numberOfRanges >= 3 else { continue }

                let widthText = RuleHelpers.string(in: file.content, for: match.range(at: 1))
                let heightText = RuleHelpers.string(in: file.content, for: match.range(at: 2))
                let width = Int(widthText) ?? 0
                let height = Int(heightText) ?? 0

                if width > 0, width < 44 || height > 0, height < 44 {
                    let snippet = RuleHelpers.string(in: file.content, for: match.range)
                    let line = RuleHelpers.lineNumber(in: file.content, for: snippet)
                    findings.append(
                        AccessibilityFinding(
                            ruleID: id,
                            summary: "Touch target may be smaller than 44x44 points",
                            detail: "Small interactive targets can be hard to activate for many users.",
                            severity: .warning,
                            remediation: "Increase the tappable area to at least 44x44 points or add padding around the interactive element.",
                            location: AccessibilityLocation(filePath: file.path, line: line),
                            tags: ["touch-target", "motor", "swiftui"]
                        )
                    )
                }
            }
        }

        return findings
    }
}
