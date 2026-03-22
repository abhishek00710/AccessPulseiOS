import SwiftUI

public struct AccessibleSecureField: View {
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

            SecureField(title, text: $text, prompt: Text(prompt))
                .textFieldStyle(.roundedBorder)
                .padding(.vertical, 4)
                .accessibilityLabel(title)
                .accessibilityValue(text.isEmpty ? Text("Empty secure text field") : Text("Entered"))
                .accessibilityHintIfPresent(accessibilityHint)
        }
    }
}
