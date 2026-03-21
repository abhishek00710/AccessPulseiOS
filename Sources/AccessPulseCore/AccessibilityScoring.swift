import Foundation

public enum AccessibilityScorer {
    public static func score(moduleName: String, findings: [AccessibilityFinding], totalChecks: Int) -> AccessibilityScorecard {
        let penalty = findings.reduce(0) { $0 + $1.severity.weight }
        let rawScore = 100 - penalty
        let passedChecks = max(0, totalChecks - findings.count)
        return AccessibilityScorecard(
            moduleName: moduleName,
            score: rawScore,
            totalChecks: totalChecks,
            passedChecks: passedChecks,
            findingCount: findings.count
        )
    }
}
