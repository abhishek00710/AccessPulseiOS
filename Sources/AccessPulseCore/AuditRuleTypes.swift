import Foundation

public struct SourceFile: Sendable, Hashable {
    public let path: String
    public let content: String

    public init(path: String, content: String) {
        self.path = path
        self.content = content
    }
}

public struct AuditContext: Sendable {
    public let sourceRoot: String
    public let moduleName: String
    public let files: [SourceFile]

    public init(sourceRoot: String, moduleName: String, files: [SourceFile]) {
        self.sourceRoot = sourceRoot
        self.moduleName = moduleName
        self.files = files
    }
}

public protocol AccessibilityRule: Sendable {
    var id: String { get }
    var name: String { get }
    func audit(in context: AuditContext) async -> [AccessibilityFinding]
}
