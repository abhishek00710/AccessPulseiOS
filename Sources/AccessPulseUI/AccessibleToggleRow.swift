import SwiftUI

public struct AccessibleToggleRow: View {
    private let title: LocalizedStringKey
    private let description: LocalizedStringKey?
    @Binding private var isOn: Bool

    public init(
        title: LocalizedStringKey,
        description: LocalizedStringKey? = nil,
        isOn: Binding<Bool>
    ) {
        self.title = title
        self.description = description
        self._isOn = isOn
    }

    public var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body.weight(.semibold))

                if let description {
                    Text(description)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .toggleStyle(.switch)
        .minimumAccessibleTapArea()
        .accessibilityElement(children: .combine)
    }
}
