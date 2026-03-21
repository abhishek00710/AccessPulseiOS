import AccessPulseUI
import SwiftUI

struct ComponentGalleryScreen: View {
    @State private var name = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    AccessibleFormField(
                        title: "Full name",
                        text: $name,
                        prompt: "Add your full name",
                        accessibilityHint: "Required before continuing to payment"
                    )

                    AccessibleButton(
                        accessibilityLabel: "Save profile changes",
                        accessibilityHint: "Double tap to save your profile information"
                    ) {
                        Label("Save changes", systemImage: "square.and.arrow.down.fill")
                    } action: {}

                    DemoUIKitCard()
                        .frame(height: 120)
                }
                .padding()
            }
            .navigationTitle("Components")
        }
    }
}

private struct DemoUIKitCard: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        AccessibleCardView(
            title: "Shipment update",
            detail: "VoiceOver reads the title and detail together as one coherent summary."
        )
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
