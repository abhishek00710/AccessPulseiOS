import Foundation

public enum AccessibilityReportFormatter {
    public static func markdown(_ report: AccessibilityReport) -> String {
        var lines: [String] = []
        lines.append("# AccessPulse Report")
        lines.append("")
        lines.append("- Score: \(report.scorecard.score)/100")
        lines.append("- Checks passed: \(report.scorecard.passedChecks)/\(report.scorecard.totalChecks)")
        lines.append("- Findings: \(report.findings.count)")
        lines.append("")

        if report.findings.isEmpty {
            lines.append("No accessibility findings were detected by the enabled rules.")
            return lines.joined(separator: "\n")
        }

        lines.append("## Findings")
        lines.append("")

        for (index, finding) in report.findings.enumerated() {
            lines.append("\(index + 1). [\(finding.severity.rawValue)] `\(finding.ruleID)`")
            lines.append("   \(finding.summary)")
            lines.append("   Location: `\(finding.location.filePath):\(finding.location.line)`")
            lines.append("   Remediation: \(finding.remediation)")
        }

        return lines.joined(separator: "\n")
    }

    public static func json(_ report: AccessibilityReport) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(report)
        return String(decoding: data, as: UTF8.self)
    }
}
