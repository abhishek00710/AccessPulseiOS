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

    public static func sarif(_ report: AccessibilityReport) throws -> String {
        let driver = SARIFDriver(
            name: "AccessPulse iOS",
            informationURI: "https://github.com/abhishek00710/AccessPulseiOS",
            rules: sarifRules(from: report.findings)
        )

        let run = SARIFRun(
            tool: SARIFTool(driver: driver),
            results: report.findings.map { finding in
                SARIFResult(
                    ruleID: finding.ruleID,
                    level: sarifLevel(for: finding.severity),
                    message: SARIFMessage(
                        text: "\(finding.summary) \(finding.remediation)"
                    ),
                    locations: [
                        SARIFLocation(
                            physicalLocation: SARIFPhysicalLocation(
                                artifactLocation: SARIFArtifactLocation(uri: finding.location.filePath),
                                region: SARIFRegion(
                                    startLine: finding.location.line,
                                    startColumn: finding.location.column
                                )
                            )
                        )
                    ],
                    properties: SARIFResultProperties(
                        tags: finding.tags,
                        severity: finding.severity.rawValue
                    )
                )
            },
            invocations: [
                SARIFInvocation(
                    executionSuccessful: true
                )
            ]
        )

        let log = SARIFLog(
            version: "2.1.0",
            schema: "https://json.schemastore.org/sarif-2.1.0.json",
            runs: [run]
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(log)
        return String(decoding: data, as: UTF8.self)
    }

    private static func sarifRules(from findings: [AccessibilityFinding]) -> [SARIFRule] {
        let grouped = Dictionary(grouping: findings, by: \.ruleID)
        return grouped.keys.sorted().compactMap { ruleID in
            guard let finding = grouped[ruleID]?.first else {
                return nil
            }

            return SARIFRule(
                id: ruleID,
                shortDescription: SARIFMessage(text: finding.summary),
                fullDescription: SARIFMessage(text: finding.detail),
                help: SARIFMessage(text: finding.remediation),
                properties: SARIFRuleProperties(
                    tags: finding.tags,
                    precision: "medium"
                )
            )
        }
    }

    private static func sarifLevel(for severity: AccessibilitySeverity) -> String {
        switch severity {
        case .error: return "error"
        case .warning: return "warning"
        case .info: return "note"
        }
    }
}

private struct SARIFLog: Encodable {
    let version: String
    let schema: String
    let runs: [SARIFRun]

    enum CodingKeys: String, CodingKey {
        case version
        case schema = "$schema"
        case runs
    }
}

private struct SARIFRun: Encodable {
    let tool: SARIFTool
    let results: [SARIFResult]
    let invocations: [SARIFInvocation]
}

private struct SARIFTool: Encodable {
    let driver: SARIFDriver
}

private struct SARIFDriver: Encodable {
    let name: String
    let informationURI: String
    let rules: [SARIFRule]

    enum CodingKeys: String, CodingKey {
        case name
        case informationURI = "informationUri"
        case rules
    }
}

private struct SARIFRule: Encodable {
    let id: String
    let shortDescription: SARIFMessage
    let fullDescription: SARIFMessage
    let help: SARIFMessage
    let properties: SARIFRuleProperties
}

private struct SARIFRuleProperties: Encodable {
    let tags: [String]
    let precision: String
}

private struct SARIFResult: Encodable {
    let ruleID: String
    let level: String
    let message: SARIFMessage
    let locations: [SARIFLocation]
    let properties: SARIFResultProperties

    enum CodingKeys: String, CodingKey {
        case ruleID = "ruleId"
        case level
        case message
        case locations
        case properties
    }
}

private struct SARIFResultProperties: Encodable {
    let tags: [String]
    let severity: String
}

private struct SARIFMessage: Encodable {
    let text: String
}

private struct SARIFLocation: Encodable {
    let physicalLocation: SARIFPhysicalLocation
}

private struct SARIFPhysicalLocation: Encodable {
    let artifactLocation: SARIFArtifactLocation
    let region: SARIFRegion
}

private struct SARIFArtifactLocation: Encodable {
    let uri: String
}

private struct SARIFRegion: Encodable {
    let startLine: Int
    let startColumn: Int
}

private struct SARIFInvocation: Encodable {
    let executionSuccessful: Bool
}
