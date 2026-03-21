import SwiftUI

struct RemediationPlaygroundScreen: View {
    private let examples: [RemediationExample] = [
        .init(
            title: "Missing labels",
            before: "Image(systemName: \"trash\")",
            after: "Image(systemName: \"trash\")\n  .accessibilityLabel(\"Delete item\")"
        ),
        .init(
            title: "Small hit areas",
            before: ".frame(width: 28, height: 28)",
            after: ".padding(10)\n  .contentShape(Rectangle())"
        ),
        .init(
            title: "Fixed fonts",
            before: ".font(.system(size: 14))",
            after: ".font(.body)"
        )
    ]

    var body: some View {
        NavigationStack {
            List(examples) { example in
                VStack(alignment: .leading, spacing: 10) {
                    Text(example.title)
                        .font(.headline)

                    Text("Before")
                        .font(.subheadline.bold())
                    Text(example.before)
                        .font(.system(.body, design: .monospaced))

                    Text("After")
                        .font(.subheadline.bold())
                    Text(example.after)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.green)
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("Remediation")
        }
    }
}

private struct RemediationExample: Identifiable {
    let id = UUID()
    let title: String
    let before: String
    let after: String
}
