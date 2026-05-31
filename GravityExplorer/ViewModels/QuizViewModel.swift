import Foundation
import SwiftUI

// MARK: - Quiz View Model
@MainActor
class QuizViewModel: ObservableObject {
    @Published var questions: [QuizQuestion] = []
    @Published var currentIndex: Int = 0
    @Published var score: Int = 0
    @Published var selectedAnswer: Int? = nil
    @Published var isAnswered: Bool = false
    @Published var isQuizActive: Bool = false

    var selectedModuleId: Int? = nil

    var currentQuestion: QuizQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(questions.count)
    }

    var isComplete: Bool {
        currentIndex >= questions.count && !questions.isEmpty
    }

    var scorePercentage: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(score) / Double(questions.count) * 100
    }

    var totalQuestions: Int { questions.count }

    // MARK: - Actions

    func startQuiz(moduleId: Int?) {
        selectedModuleId = moduleId
        if let id = moduleId {
            questions = QuizQuestion.questions(for: id).shuffled()
        } else {
            questions = QuizQuestion.allQuestions.shuffled()
        }
        currentIndex = 0
        score = 0
        selectedAnswer = nil
        isAnswered = false
        isQuizActive = true
    }

    func selectAnswer(_ index: Int) {
        guard !isAnswered else { return }
        selectedAnswer = index
        isAnswered = true
        if index == currentQuestion?.correctIndex {
            score += 1
        }
    }

    func nextQuestion() {
        currentIndex += 1
        selectedAnswer = nil
        isAnswered = false
    }

    func reset() {
        questions = []
        currentIndex = 0
        score = 0
        selectedAnswer = nil
        isAnswered = false
        isQuizActive = false
        selectedModuleId = nil
    }
}
