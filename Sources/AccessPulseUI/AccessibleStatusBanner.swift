import SwiftUI

public struct AccessibleStatusBanner: View {
    public enum Tone: Sendable {
        case info
        case success
        case warning

        var iconName: String {
            switch self {
            case .info: "info.circle.fill"
            case .success: "checkmark.circle.fill"
            case .warning: "exclamationmark.triangle.fill"
            }
        }

        var tint: Color {
            switch self {
            case .info: .blue
            case .success: .green
            case .warning: .orange
            }
        }
    }

    private let title: LocalizedStringKey
    private let message: LocalizedStringKey
    private let tone: Tone

    public init(title: LocalizedStringKey, message: LocalizedStringKey, tone: Tone) {
        self.title = title
        self.message = message
        self.tone = tone
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: tone.iconName)
                .foregroundStyle(tone.tint)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(message)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tone.tint.opacity(0.08), in: RoundedRectangle(cornerRadius: 18))
        .accessibilityElement(children: .combine)
    }
}
