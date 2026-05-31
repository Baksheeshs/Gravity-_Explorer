import SwiftUI

// MARK: - Main Tab View
struct MainTabView: View {
    var body: some View {
        TabView {
            // Tab 1: Educational Modules
            HomeView()
                .tabItem {
                    Image(systemName: "square.grid.2x2.fill")
                    Text("Modules")
                }

            // Tab 2: 3D Solar System Sandbox (Placeholder)
            SolarSystemView()
                .tabItem {
                    Image(systemName: "sun.dust.fill")
                    Text("Sandbox")
                }

            // Tab 3: Quiz
            QuizHomeView()
                .tabItem {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Quiz")
                }

            // Tab 4: AI Assistant
            if #available(iOS 26.0, *) {
                AIChatView()
                    .tabItem {
                        Image(systemName: "brain.head.profile")
                        Text("Ask AI")
                    }
            } else {
                // Fallback on earlier versions
            }
        }
        .tint(Theme.starGlow) // Tint for the selected tab
    }
}
