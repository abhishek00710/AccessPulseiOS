import SwiftUI

public extension View {
    func accessibilityHintIfPresent(_ hint: LocalizedStringKey?) -> some View {
        modifier(AccessibilityHintModifier(hint: hint))
    }

    func minimumAccessibleTapArea() -> some View {
        modifier(MinimumAccessibleTapAreaModifier())
    }
}

private struct AccessibilityHintModifier: ViewModifier {
    let hint: LocalizedStringKey?

    @ViewBuilder
    func body(content: Content) -> some View {
        if let hint {
            content.accessibilityHint(hint)
        } else {
            content
        }
    }
}

private struct MinimumAccessibleTapAreaModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
    }
}
