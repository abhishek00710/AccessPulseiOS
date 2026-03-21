import AccessPulseCore
import Foundation

public struct FixedFontDynamicTypeRule: AccessibilityRule {
    public let id = "fixed_font_dynamic_type_risk"
    public let name = "Fixed Font Dynamic Type Risk"

    public init() {}

    public func audit(in context: AuditContext) async -> [AccessibilityFinding] {
        var findings: [AccessibilityFinding] = []
        let pattern = #"\.font\s*\(\s*\.system\s*\(\s*size:\s*(\d+)"#

        for file in context.files {
            let matches = RuleHelpers.regexMatches(pattern: pattern, in: file.content)
            for match in matches {
                let snippet = RuleHelpers.string(in: file.content, for: match.range)
                let sizeText = RuleHelpers.string(in: file.content, for: match.range(at: 1))
                let size = Int(sizeText) ?? 0
                if size == 0 || size >= 30 {
                    continue
                }

                let line = RuleHelpers.lineNumber(in: file.content, for: snippet)
                findings.append(
                    AccessibilityFinding(
                        ruleID: id,
                        summary: "Fixed system font may not scale well with Dynamic Type",
                        detail: "Hard-coded font sizes often need extra care to remain legible across accessibility sizes.",
                        severity: .info,
                        remediation: "Prefer semantic text styles such as `.body` or use `Font.custom(_:size:relativeTo:)` so the text scales with Dynamic Type.",
                        location: AccessibilityLocation(filePath: file.path, line: line),
                        tags: ["dynamic-type", "typography", "swiftui"]
                    )
                )
            }
        }

        return findings
    }
}
