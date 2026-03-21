import Foundation

public enum AccessibilitySeverity: String, Codable, Sendable, Hashable, CaseIterable {
    case info
    case warning
    case error

    public var weight: Int {
        switch self {
        case .info: 1
        case .warning: 4
        case .error: 8
        }
    }
}

public struct AccessibilityLocation: Codable, Sendable, Hashable {
    public let filePath: String
    public let line: Int
    public let column: Int

    public init(filePath: String, line: Int, column: Int = 1) {
        self.filePath = filePath
        self.line = line
        self.column = column
    }
}

public struct AccessibilityFinding: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public let ruleID: String
    public let summary: String
    public let detail: String
    public let severity: AccessibilitySeverity
    public let remediation: String
    public let location: AccessibilityLocation
    public let tags: [String]

    public init(
        id: UUID = UUID(),
        ruleID: String,
        summary: String,
        detail: String,
        severity: AccessibilitySeverity,
        remediation: String,
        location: AccessibilityLocation,
        tags: [String] = []
    ) {
        self.id = id
        self.ruleID = ruleID
        self.summary = summary
        self.detail = detail
        self.severity = severity
        self.remediation = remediation
        self.location = location
        self.tags = tags
    }
}

public struct AccessibilityScorecard: Codable, Sendable, Hashable {
    public let moduleName: String
    public let score: Int
    public let totalChecks: Int
    public let passedChecks: Int
    public let findingCount: Int

    public init(moduleName: String, score: Int, totalChecks: Int, passedChecks: Int, findingCount: Int) {
        self.moduleName = moduleName
        self.score = max(0, min(100, score))
        self.totalChecks = totalChecks
        self.passedChecks = passedChecks
        self.findingCount = findingCount
    }
}

public struct AccessibilityReport: Codable, Sendable, Hashable {
    public let generatedAt: Date
    public let findings: [AccessibilityFinding]
    public let scorecard: AccessibilityScorecard

    public init(generatedAt: Date = .now, findings: [AccessibilityFinding], scorecard: AccessibilityScorecard) {
        self.generatedAt = generatedAt
        self.findings = findings.sorted {
            if $0.severity.weight == $1.severity.weight {
                return $0.location.filePath < $1.location.filePath
            }
            return $0.severity.weight > $1.severity.weight
        }
        self.scorecard = scorecard
    }
}
