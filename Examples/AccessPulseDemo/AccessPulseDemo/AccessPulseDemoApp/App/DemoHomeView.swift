import SwiftUI

struct DemoHomeView: View {
    var body: some View {
        TabView {
            AuditOverviewScreen()
                .tabItem {
                    Label("Report", systemImage: "waveform.path.ecg")
                }

            ComponentGalleryScreen()
                .tabItem {
                    Label("Components", systemImage: "square.grid.2x2")
                }

            RemediationPlaygroundScreen()
                .tabItem {
                    Label("Fixes", systemImage: "figure.roll")
                }
        }
    }
}
