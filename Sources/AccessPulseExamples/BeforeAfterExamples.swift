import AccessPulseUI
import SwiftUI

public struct BeforeAfterExamples: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isVoiceOverHintsEnabled = true

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Before")
                    .font(.title2.bold())

                VStack(alignment: .leading, spacing: 12) {
                    Image(systemName: "tray.full.fill")
                    Button(action: {}) {
                        Image(systemName: "paperplane.fill")
                    }
                    .frame(width: 28, height: 28)

                    Text("Checkout")
                        .font(.system(size: 14))
                }
                .padding()
                .background(.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))

                Text("After")
                    .font(.title2.bold())

                VStack(spacing: 16) {
                    AccessibleStatusBanner(
                        title: "Accessibility upgrade",
                        message: "This version uses labeled fields, larger touch targets, and VoiceOver-friendly actions.",
                        tone: .success
                    )

                    AccessibleFormField(
                        title: "Email",
                        text: $email,
                        prompt: "name@example.com",
                        accessibilityHint: "Used for receipts and order updates"
                    )

                    AccessibleSecureField(
                        title: "Password",
                        text: $password,
                        prompt: "Enter your password",
                        accessibilityHint: "Must be at least 8 characters"
                    )

                    AccessibleToggleRow(
                        title: "VoiceOver hints",
                        description: "Keep extra spoken guidance enabled during checkout.",
                        isOn: $isVoiceOverHintsEnabled
                    )

                    AccessibleButton(
                        accessibilityLabel: "Send checkout confirmation",
                        accessibilityHint: "Double tap to continue to the confirmation screen"
                    ) {
                        Label("Continue", systemImage: "paperplane.fill")
                    } action: {}
                }
                .padding()
                .background(.green.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
            }
            .padding()
        }
    }
}
