import AccessPulseCore
import AccessPulseSyntaxRules
import Foundation

public struct RuleSet: Sendable {
    public var rules: [any AccessibilityRule]

    public init(rules: [any AccessibilityRule]) {
        self.rules = rules
    }

    public static let `default` = RuleSet(
        rules: [
            MissingAccessibilityLabelRule(),
            TouchTargetRule(),
            FixedFontDynamicTypeRule(),
            DynamicTypeClampRule(),
            AccessibilityHiddenInteractiveRule(),
            PlaceholderOnlyTextFieldRule()
        ]
    )

    public mutating func register(_ rule: any AccessibilityRule) {
        rules.append(rule)
    }
}
