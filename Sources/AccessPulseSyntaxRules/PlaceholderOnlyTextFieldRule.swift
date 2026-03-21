import AccessPulseCore
import Foundation
import SwiftParser
import SwiftSyntax

public struct PlaceholderOnlyTextFieldRule: AccessibilityRule {
    public let id = "placeholder_only_textfield"
    public let name = "Placeholder-only TextField"

    public init() {}

    public func audit(in context: AuditContext) async -> [AccessibilityFinding] {
        context.files.flatMap { file in
            let tree = Parser.parse(source: file.content)
            let visitor = PlaceholderOnlyTextFieldVisitor(filePath: file.path, tree: tree)
            visitor.walk(tree)
            return visitor.findings
        }
    }
}
