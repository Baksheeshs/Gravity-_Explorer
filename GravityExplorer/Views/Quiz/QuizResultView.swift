import SwiftUI

// MARK: - Quiz Result View
struct QuizResultView: View {
    @ObservedObject var viewModel: QuizViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var animateScore = false
    @State private var showConfetti = false

    private var message: (emoji: String, text: String) {
        let pct = viewModel.scorePercentage
        if pct >= 90 { return ("🌟", "Gravity Master!") }
        if pct >= 70 { return ("👏", "Great Job!") }
        if pct >= 50 { return ("🚀", "Keep Exploring!") }
        return ("💪", "Try Again!")
    }

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            // Confetti particles for high scores
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 28) {
                    Spacer().frame(height: 30)

                    // Emoji
                    Text(message.emoji)
                        .font(.system(size: 56))
                        .scaleEffect(animateScore ? 1.0 : 0.3)
                        .animation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.2), value: animateScore)

                    // Score Ring
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.06), lineWidth: 12)
                            .frame(width: 160, height: 160)

                        Circle()
                            .trim(from: 0, to: animateScore ? CGFloat(viewModel.scorePercentage / 100) : 0)
                            .stroke(
                                LinearGradient(
                                    colors: scoreGradientColors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .frame(width: 160, height: 160)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 1.2).delay(0.3), value: animateScore)

                        VStack(spacing: 4) {
                            Text("\(viewModel.score)/\(viewModel.totalQuestions)")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            Text("\(Int(viewModel.scorePercentage))%")
                                .font(Theme.subtitle(16))
                                .foregroundColor(Theme.secondaryText)
                        }
                    }

                    // Message
                    Text(message.text)
                        .font(Theme.title(26))
                        .foregroundStyle(
                            LinearGradient(
                                colors: scoreGradientColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    // Score breakdown
                    scoreBreakdown
                        .padding(.horizontal, 20)

                    // Buttons
                    VStack(spacing: 12) {
                        // Try Again
                        Button {
                            viewModel.startQuiz(moduleId: viewModel.selectedModuleId)
                            HapticManager.shared.selection()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Try Again")
                            }
                            .font(Theme.subtitle(16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Theme.auroraGreen, Theme.cosmicCyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        // Back to Quizzes
                        Button {
                            viewModel.reset()
                            dismiss()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.left")
                                Text("Back to Quizzes")
                            }
                            .font(Theme.subtitle(16))
                            .foregroundColor(Theme.secondaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateScore = true
            }
            if viewModel.scorePercentage >= 70 {
                showConfetti = true
            }
        }
    }

    private var scoreGradientColors: [Color] {
        let pct = viewModel.scorePercentage
        if pct >= 80 { return [Theme.auroraGreen, Theme.cosmicCyan] }
        if pct >= 50 { return [Theme.solarOrange, Theme.starGlow] }
        return [Theme.plasmaRed, Theme.solarOrange]
    }

    // MARK: - Score Breakdown
    private var scoreBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(Theme.subtitle(14))
                .foregroundColor(Theme.secondaryText)

            HStack(spacing: 16) {
                summaryItem(label: "Correct", value: "\(viewModel.score)", color: Theme.auroraGreen, icon: "checkmark.circle.fill")
                summaryItem(label: "Incorrect", value: "\(viewModel.totalQuestions - viewModel.score)", color: Theme.plasmaRed, icon: "xmark.circle.fill")
                summaryItem(label: "Total", value: "\(viewModel.totalQuestions)", color: Theme.starGlow, icon: "questionmark.circle.fill")
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 16)
    }

    private func summaryItem(label: String, value: String, color: Color, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .monospaced))
                .foregroundColor(color)

            Text(label)
                .font(Theme.caption(10))
                .foregroundColor(Theme.dimText)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Simple Confetti Effect
struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []

    struct ConfettiParticle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        let size: CGFloat
        let color: Color
        let rotation: Double
        let delay: Double
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size * 0.6)
                        .rotationEffect(.degrees(particle.rotation))
                        .position(x: particle.x, y: particle.y)
                        .opacity(particle.y < geo.size.height ? 1 : 0)
                }
            }
            .onAppear {
                generateParticles(in: geo.size)
                animateParticles(in: geo.size)
            }
        }
    }

    private func generateParticles(in size: CGSize) {
        let colors: [Color] = [Theme.auroraGreen, Theme.cosmicCyan, Theme.starGlow, Theme.solarOrange, .yellow, .white]
        particles = (0..<40).map { _ in
            ConfettiParticle(
                x: CGFloat.random(in: 0...size.width),
                y: -20,
                size: CGFloat.random(in: 6...12),
                color: colors.randomElement()!,
                rotation: Double.random(in: 0...360),
                delay: Double.random(in: 0...1.5)
            )
        }
    }

    private func animateParticles(in size: CGSize) {
        for i in particles.indices {
            let delay = particles[i].delay
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeIn(duration: Double.random(in: 2.0...4.0))) {
                    particles[i].y = size.height + 30
                    particles[i].x += CGFloat.random(in: -50...50)
                }
            }
        }
    }
}
