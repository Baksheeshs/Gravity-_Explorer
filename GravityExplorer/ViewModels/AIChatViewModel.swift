import Foundation
import SwiftUI
import FoundationModels

// MARK: - Chat Message Model
struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let isError: Bool
    let timestamp: Date

    init(content: String, isUser: Bool, isError: Bool = false) {
        self.content = content
        self.isUser = isUser
        self.isError = isError
        self.timestamp = Date()
    }
}

// MARK: - AI Chat View Model
@available(iOS 26.0, *)
@MainActor
class AIChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isThinking: Bool = false

    private let ragEngine = GravityRAGEngine.shared

    var isModelAvailable: Bool {
        GravityRAGEngine.isAvailable
    }

    var unavailabilityMessage: String {
        GravityRAGEngine.unavailabilityReason
    }

    let suggestedQuestions: [String] = [
        "What is gravity?",
        "How do black holes work?",
        "What happens in zero gravity?",
        "Why is Jupiter's gravity so strong?",
        "What is the difference between G and g?",
        "How do tides work?",
        "Can we create artificial gravity?",
        "What is gravitational time dilation?"
    ]

    // MARK: - Send Message

    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isThinking else { return }

        // Add user message
        let userMessage = ChatMessage(content: text, isUser: true)
        messages.append(userMessage)
        inputText = ""

        // Haptic feedback on send
        HapticManager.shared.impact(.light)

        // Start thinking
        isThinking = true

        // Call Foundation Models asynchronously
        Task { @MainActor in
            do {
                let response = try await ragEngine.query(text)
                let aiMessage = ChatMessage(content: response, isUser: false)
                messages.append(aiMessage)
                HapticManager.shared.impact(.medium)
            } catch {
                let errorMessage = ChatMessage(
                    content: "I had trouble generating a response. Please try again! 🔄",
                    isUser: false,
                    isError: true
                )
                messages.append(errorMessage)
                HapticManager.shared.notification(.error)
            }
            isThinking = false
        }
    }

    func sendSuggestedQuestion(_ question: String) {
        inputText = question
        sendMessage()
    }

    func clearChat() {
        messages.removeAll()
        ragEngine.resetSession()
        HapticManager.shared.impact(.light)
    }
}
