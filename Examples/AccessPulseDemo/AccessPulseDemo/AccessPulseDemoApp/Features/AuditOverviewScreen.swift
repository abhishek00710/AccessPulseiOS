import AccessPulseUI
import SwiftUI

struct AuditOverviewScreen: View {
    private let reportRows: [DemoFinding] = [
        .init(title: "Labels", detail: "2 controls need better VoiceOver names", score: 82),
        .init(title: "Touch Targets", detail: "1 icon button is smaller than 44x44", score: 76),
        .init(title: "Dynamic Type", detail: "Semantic styles adopted in most flows", score: 91)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Accessibility Score")
                            .font(.title.bold())
                        Text("87 / 100")
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundStyle(.green)
                        Text("VoiceOver labels and touch targets are the biggest remaining opportunities.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    ForEach(reportRows) { row in
                        DemoScoreCard(row: row)
                    }
                }
                .padding()
            }
            .navigationTitle("AccessPulse")
        }
    }
}

private struct DemoFinding: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let score: Int
}

private struct DemoScoreCard: View {
    let row: DemoFinding

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(row.title)
                    .font(.headline)
                Spacer()
                Text("\(row.score)")
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(row.score > 84 ? .green : .orange)
            }

            Text(row.detail)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18))
        .accessibilityElement(children: .combine)
    }
}
