import AccessPulseCore
import Foundation

public actor AuditEngine {
    private let rules: [any AccessibilityRule]

    public init(ruleSet: RuleSet = .default) {
        self.rules = ruleSet.rules
    }

    public func run(on context: AuditContext) async -> AccessibilityReport {
        let findings = await withTaskGroup(of: [AccessibilityFinding].self) { group in
            for rule in rules {
                group.addTask {
                    await rule.audit(in: context)
                }
            }

            var allFindings: [AccessibilityFinding] = []
            for await result in group {
                allFindings.append(contentsOf: result)
            }
            return allFindings
        }

        let scorecard = AccessibilityScorer.score(
            moduleName: context.moduleName,
            findings: findings,
            totalChecks: max(rules.count * max(context.files.count, 1), rules.count)
        )

        return AccessibilityReport(findings: findings, scorecard: scorecard)
    }
}
