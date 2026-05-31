import SwiftUI

// MARK: - Home View
struct HomeView: View {
    @State private var titleGlow = false

    let gridColumns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Theme.backgroundGradient.ignoresSafeArea()
                StarfieldView()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Header
                        headerSection

                        // Module Grid
                        LazyVGrid(columns: gridColumns, spacing: 14) {
                            ForEach(Array(modules.enumerated()), id: \.element.id) { index, module in
                                NavigationLink(destination: destinationView(for: module)) {
                                    ModuleCardView(module: module, index: index)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)

                        // Footer
                        footerSection
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
        .tint(Theme.starGlow)
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 8) {
            Spacer().frame(height: 20)

            // Logo area
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Theme.starGlow.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 5,
                            endRadius: 60
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: titleGlow ? 15 : 8)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: titleGlow)

                Image(systemName: "globe.americas.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.starGlow, Theme.cosmicCyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .onAppear { titleGlow = true }

            Text("Gravity Explorer")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.53, green: 0.81, blue: 0.98))

            Text("Feel the Force")
                .font(Theme.subtitle(16))
                .foregroundColor(Theme.secondaryText)
                .tracking(4)
                .textCase(.uppercase)
        }
        .padding(.top, 10)
    }

    // MARK: - Footer
    private var footerSection: some View {
        VStack(spacing: 6) {
            Capsule()
                .fill(Theme.starGlow.opacity(0.2))
                .frame(width: 40, height: 4)

            Text("Explore. Experiment. Understand.")
                .font(Theme.caption(12))
                .foregroundColor(Theme.dimText)
        }
        .padding(.top, 10)
    }

    // MARK: - Navigation Destinations
    @ViewBuilder
    private func destinationView(for module: ModuleInfo) -> some View {
        switch module.id {
        case 1:
            WhatIsGravityView()
        case 2:
            GvsGView()
        case 3:
            AccelerationView()
        case 4:
            ZeroGravityView()
        case 5:
            HumanBodyView()
        case 6:
            PlanetGravityView()
        default:
            Text("Coming Soon")
        }
    }
}
