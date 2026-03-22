import AccessPulseCore
import Foundation

public struct DynamicTypeClampRule: AccessibilityRule {
    public let id = "dynamic_type_clamp_risk"
    public let name = "Dynamic Type Clamp Risk"

    public init() {}

    public func audit(in context: AuditContext) async -> [AccessibilityFinding] {
        var findings: [AccessibilityFinding] = []
        let pattern = #"\.dynamicTypeSize\s*\(([^)]*)\)"#

        for file in context.files {
            let matches = RuleHelpers.regexMatches(pattern: pattern, in: file.content)
            for match in matches {
                let clause = RuleHelpers.string(in: file.content, for: match.range(at: 1))
                guard clause.contains("..."), clause.contains(".large") || clause.contains(".medium") || clause.contains(".small") else {
                    continue
                }

                let snippet = RuleHelpers.string(in: file.content, for: match.range)
                let line = RuleHelpers.lineNumber(in: file.content, for: snippet)
                findings.append(
                    AccessibilityFinding(
                        ruleID: id,
                        summary: "Dynamic Type range appears to be clamped",
                        detail: "Restricting Dynamic Type can prevent people using accessibility text sizes from reading content comfortably.",
                        severity: .warning,
                        remediation: "Avoid tight `.dynamicTypeSize(...)` limits unless the layout has a strong accessibility reason and an alternative readable presentation.",
                        location: AccessibilityLocation(filePath: file.path, line: line),
                        tags: ["dynamic-type", "scaling", "swiftui"]
                    )
                )
            }
        }

        return findings
    }
}
