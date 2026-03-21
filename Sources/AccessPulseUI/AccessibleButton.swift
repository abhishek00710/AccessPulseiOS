import AccessPulseCore
import SwiftUI

public struct AccessibleButton<Label: View>: View {
    private let accessibilityLabel: LocalizedStringKey
    private let accessibilityHint: LocalizedStringKey?
    private let action: () -> Void
    private let label: () -> Label

    public init(
        accessibilityLabel: LocalizedStringKey,
        accessibilityHint: LocalizedStringKey? = nil,
        @ViewBuilder label: @escaping () -> Label,
        action: @escaping () -> Void
    ) {
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.label = label
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            label()
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .contentShape(Rectangle())
        .accessibilityLabel(accessibilityLabel)
        .applyHint(accessibilityHint)
    }
}

private extension View {
    @ViewBuilder
    func applyHint(_ hint: LocalizedStringKey?) -> some View {
        if let hint {
            accessibilityHint(hint)
        } else {
            self
        }
    }
}
