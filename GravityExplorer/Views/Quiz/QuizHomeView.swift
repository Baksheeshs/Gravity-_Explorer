import SwiftUI

// MARK: - Quiz Home View
struct QuizHomeView: View {
    @StateObject private var viewModel = QuizViewModel()
    @State private var titleGlow = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()
                StarfieldView()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        quizHeader

                        // All Modules card
                        NavigationLink {
                            QuizPlayView(viewModel: viewModel, moduleId: nil)
                        } label: {
                            allModulesCard
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)

                        // Section title
                        HStack {
                            Text("By Module")
                                .font(Theme.subtitle(14))
                                .foregroundColor(Theme.secondaryText)
                                .textCase(.uppercase)
                                .tracking(2)
                            Spacer()
                        }
                        .padding(.horizontal, 20)

                        // Module quiz cards — full-width vertical list
                        VStack(spacing: 12) {
                            ForEach(Array(modules.enumerated()), id: \.element.id) { index, module in
                                NavigationLink {
                                    QuizPlayView(viewModel: viewModel, moduleId: module.id)
                                } label: {
                                    moduleQuizCard(module: module, index: index)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .tint(Theme.starGlow)
    }

    // MARK: - Header
    private var quizHeader: some View {
        VStack(spacing: 8) {
            Spacer().frame(height: 20)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Theme.auroraGreen.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 5,
                            endRadius: 60
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: titleGlow ? 15 : 8)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: titleGlow)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.auroraGreen, Theme.cosmicCyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .onAppear { titleGlow = true }

            Text("Test Your Knowledge")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Theme.auroraGreen],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("Check what you've learned")
                .font(Theme.subtitle(14))
                .foregroundColor(Theme.secondaryText)
        }
        .padding(.top, 10)
    }

    // MARK: - All Modules Card
    private var allModulesCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Theme.starGlow.opacity(0.3), Theme.cosmicCyan.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)

                Image(systemName: "star.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Theme.starGlow)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("All Modules")
                    .font(Theme.subtitle(18))
                    .foregroundColor(.white)

                Text("30 questions across all topics")
                    .font(Theme.caption(12))
                    .foregroundColor(Theme.secondaryText)
            }

            Spacer()

            VStack(spacing: 2) {
                Text("30")
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundColor(Theme.starGlow)
                Text("Qs")
                    .font(Theme.caption(10))
                    .foregroundColor(Theme.dimText)
            }

            Image(systemName: "chevron.right.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(Theme.starGlow.opacity(0.6))
        }
        .padding(18)
        .glassCard(cornerRadius: 18)
        .shadow(color: Theme.starGlow.opacity(0.12), radius: 12, x: 0, y: 6)
    }

    // MARK: - Module Quiz Card (Full-Width Horizontal)
    private func moduleQuizCard(module: ModuleInfo, index: Int) -> some View {
        HStack(spacing: 14) {
            // Numbered badge with module accent color
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [module.accentColor.opacity(0.25), module.accentColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(module.accentColor.opacity(0.3), lineWidth: 1)
                    )

                Image(systemName: module.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(module.accentColor)
            }

            // Module info
            VStack(alignment: .leading, spacing: 3) {
                Text(module.title)
                    .font(Theme.subtitle(15))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(module.subtitle)
                    .font(Theme.caption(12))
                    .foregroundColor(Theme.dimText)
                    .lineLimit(1)
            }

            Spacer()

            // Question count pill
            Text("5 Qs")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(module.accentColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(module.accentColor.opacity(0.12))
                        .overlay(
                            Capsule()
                                .stroke(module.accentColor.opacity(0.2), lineWidth: 0.5)
                        )
                )

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.dimText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [module.accentColor.opacity(0.15), Color.white.opacity(0.05)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 0.5
                        )
                )
        )
        .overlay(
            // Subtle left accent bar
            HStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(module.accentColor.opacity(0.6))
                    .frame(width: 3)
                    .padding(.vertical, 10)
                Spacer()
            }
        )
    }
}
