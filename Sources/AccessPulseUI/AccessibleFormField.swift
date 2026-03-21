import SwiftUI

public struct AccessibleFormField: View {
    private let title: LocalizedStringKey
    @Binding private var text: String
    private let prompt: LocalizedStringKey
    private let accessibilityHint: LocalizedStringKey?

    public init(
        title: LocalizedStringKey,
        text: Binding<String>,
        prompt: LocalizedStringKey,
        accessibilityHint: LocalizedStringKey? = nil
    ) {
        self.title = title
        self._text = text
        self.prompt = prompt
        self.accessibilityHint = accessibilityHint
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            TextField(title, text: $text, prompt: Text(prompt))
                .textFieldStyle(.roundedBorder)
                .padding(.vertical, 4)
                .accessibilityLabel(title)
                .accessibilityValue(text.isEmpty ? Text("Empty") : Text(verbatim: text))
                .applyHint(accessibilityHint)
        }
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
