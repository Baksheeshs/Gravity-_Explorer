import SwiftUI

// MARK: - Quiz Play View
struct QuizPlayView: View {
    @ObservedObject var viewModel: QuizViewModel
    @Environment(\.dismiss) private var dismiss
    let moduleId: Int?

    @State private var animateProgress = false
    @State private var showExplanation = false
    @State private var optionAppeared = false

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            if viewModel.isComplete {
                QuizResultView(viewModel: viewModel)
            } else if let question = viewModel.currentQuestion {
                questionContent(question)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    viewModel.reset()
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Quit")
                    }
                    .font(Theme.body(15))
                    .foregroundColor(Theme.starGlow)
                }
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            viewModel.startQuiz(moduleId: moduleId)
        }
    }

    // MARK: - Question Content
    @ViewBuilder
    private func questionContent(_ question: QuizQuestion) -> some View {
        VStack(spacing: 0) {
            // Progress bar
            progressSection

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Module badge
                    if let mod = modules.first(where: { $0.id == question.moduleId }) {
                        HStack(spacing: 6) {
                            Image(systemName: mod.icon)
                                .font(.system(size: 12))
                            Text(mod.title)
                                .font(Theme.caption(12))
                        }
                        .foregroundColor(mod.accentColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(mod.accentColor.opacity(0.12))
                        .clipShape(Capsule())
                    }

                    // Question
                    Text(question.question)
                        .font(Theme.title(22))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)

                    // Options
                    VStack(spacing: 12) {
                        ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                            optionButton(index: index, text: option, question: question)
                        }
                    }
                    .padding(.horizontal, 16)

                    // Explanation
                    if viewModel.isAnswered {
                        explanationCard(question)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    // Next button
                    if viewModel.isAnswered {
                        nextButton
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.vertical, 20)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isAnswered)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.currentIndex)
    }

    // MARK: - Progress
    private var progressSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Question \(viewModel.currentIndex + 1) of \(viewModel.totalQuestions)")
                    .font(Theme.caption(13))
                    .foregroundColor(Theme.secondaryText)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.solarOrange)
                    Text("\(viewModel.score)")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Theme.solarOrange)
                }
            }
            .padding(.horizontal, 20)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [Theme.auroraGreen, Theme.cosmicCyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geo.size.width * CGFloat(Double(viewModel.currentIndex + 1) / Double(viewModel.totalQuestions)),
                            height: 6
                        )
                        .animation(.spring(response: 0.5), value: viewModel.currentIndex)
                }
            }
            .frame(height: 6)
            .padding(.horizontal, 20)
        }
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    // MARK: - Option Button
    private func optionButton(index: Int, text: String, question: QuizQuestion) -> some View {
        let isSelected = viewModel.selectedAnswer == index
        let isCorrect = index == question.correctIndex
        let showResult = viewModel.isAnswered

        let borderColor: Color = {
            if !showResult { return isSelected ? Theme.starGlow : Color.white.opacity(0.1) }
            if isCorrect { return Theme.auroraGreen }
            if isSelected && !isCorrect { return Theme.plasmaRed }
            return Color.white.opacity(0.06)
        }()

        let bgColor: Color = {
            if !showResult { return isSelected ? Theme.starGlow.opacity(0.08) : Color.white.opacity(0.04) }
            if isCorrect { return Theme.auroraGreen.opacity(0.12) }
            if isSelected && !isCorrect { return Theme.plasmaRed.opacity(0.12) }
            return Color.white.opacity(0.02)
        }()

        let leadingIcon: String = {
            if !showResult { return ["A", "B", "C", "D"][index] }
            if isCorrect { return "checkmark" }
            if isSelected && !isCorrect { return "xmark" }
            return ["A", "B", "C", "D"][index]
        }()

        return Button {
            viewModel.selectAnswer(index)
            if index == question.correctIndex {
                HapticManager.shared.impact(.medium)
            } else {
                HapticManager.shared.impact(.heavy)
            }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(borderColor.opacity(0.2))
                        .frame(width: 34, height: 34)

                    if showResult && (isCorrect || (isSelected && !isCorrect)) {
                        Image(systemName: leadingIcon)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(isCorrect ? Theme.auroraGreen : Theme.plasmaRed)
                    } else {
                        Text(leadingIcon)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Theme.secondaryText)
                    }
                }

                Text(text)
                    .font(Theme.body(15))
                    .foregroundColor(showResult && !isCorrect && !isSelected ? Theme.dimText : .white)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(bgColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(borderColor, lineWidth: showResult && isCorrect ? 2 : 1)
            )
        }
        .disabled(viewModel.isAnswered)
        .animation(.easeInOut(duration: 0.25), value: viewModel.isAnswered)
    }

    // MARK: - Explanation Card
    private func explanationCard(_ question: QuizQuestion) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
                .font(.system(size: 16))
                .padding(.top, 2)

            Text(question.explanation)
                .font(Theme.body(14))
                .foregroundColor(Theme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .glassCard(cornerRadius: 14)
        .padding(.horizontal, 16)
    }

    // MARK: - Next Button
    private var nextButton: some View {
        Button {
            viewModel.nextQuestion()
            HapticManager.shared.selection()
        } label: {
            HStack(spacing: 8) {
                Text(viewModel.currentIndex + 1 >= viewModel.totalQuestions ? "See Results" : "Next Question")
                    .font(Theme.subtitle(16))
                Image(systemName: viewModel.currentIndex + 1 >= viewModel.totalQuestions ? "chart.bar.fill" : "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
            }
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
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
    }
}
