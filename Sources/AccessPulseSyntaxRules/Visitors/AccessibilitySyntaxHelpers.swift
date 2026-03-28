import SwiftSyntax

enum AccessibilitySyntaxHelpers {
    static func calledName(for node: FunctionCallExprSyntax) -> String? {
        if let declReference = node.calledExpression.as(DeclReferenceExprSyntax.self) {
            return declReference.baseName.text
        }

        if let memberAccess = node.calledExpression.as(MemberAccessExprSyntax.self) {
            return memberAccess.declName.baseName.text
        }

        return nil
    }

    static func hasAncestorModifier(
        named name: String,
        near node: some SyntaxProtocol,
        maxDepth: Int = 8
    ) -> Bool {
        var current = Syntax(node).parent
        var depth = 0

        while let syntax = current, depth < maxDepth {
            if let functionCall = syntax.as(FunctionCallExprSyntax.self),
               calledName(for: functionCall) == name {
                return true
            }

            current = syntax.parent
            depth += 1
        }

        return false
    }
}
