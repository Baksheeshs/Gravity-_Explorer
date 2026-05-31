import Foundation
import FoundationModels

// MARK: - Gravity AI Engine (Apple Foundation Models)
@available(iOS 26.0, *)
@MainActor
class GravityRAGEngine {

    // MARK: - Singleton
    static let shared = GravityRAGEngine()

    private let gravityInstructions = """
        You are Gravity AI, an expert and enthusiastic science educator specializing in gravity, \
        space physics, and the cosmos. You are built into the Gravity Explorer app, an educational \
        iOS application that teaches people about gravity through 6 interactive modules.

        Your role:
        - Answer questions about gravity, gravitational physics, space, planets, black holes, \
          orbits, weightlessness, tidal forces, Einstein's relativity, Newton's laws, and all \
          related topics.
        - Provide accurate, scientifically correct answers with real numbers, formulas, and examples.
        - Be enthusiastic and educational — explain concepts clearly for curious learners of all ages.
        - Use relevant emojis sparingly to make responses engaging (🌍, 🚀, ⚫, 🪐, etc.).
        - Keep responses concise but informative — aim for 2-4 paragraphs maximum.
        - When relevant, mention specific values like Earth's gravity (9.81 m/s²), the gravitational \
          constant G (6.674 × 10⁻¹¹ N⋅m²/kg²), planetary surface gravities, etc.

        If asked about topics unrelated to gravity, space, or physics, politely redirect: \
        "That's a great question, but I specialize in gravity and space! Try asking me about \
        how gravity works on different planets, what causes weightlessness, or how black holes form."

        If greeted, introduce yourself warmly and suggest interesting gravity questions to explore.
        """

    private init() {}

    // MARK: - Query (Async)

    func query(_ input: String) async throws -> String {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmed.count > 1 else {
            return "Please ask me a question about gravity, space, or the universe! 🌌"
        }

        // Create a fresh session for each query to avoid context/state issues
        let session = LanguageModelSession(
            instructions: Instructions(gravityInstructions)
        )
        let response = try await session.respond(to: trimmed)
        return response.content
    }

    // MARK: - Reset (no-op now, kept for API compatibility)

    func resetSession() {
        // Each query creates its own session, so nothing to reset
    }

    // MARK: - Model Availability

    static var isAvailable: Bool {
        if #available(iOS 26.0, *) {
            let model = SystemLanguageModel.default
            if case .available = model.availability {
                return true
            }
        }
        return false
    }

    static var unavailabilityReason: String {
        if #available(iOS 26.0, *) {
            let model = SystemLanguageModel.default
            switch model.availability {
            case .available:
                return ""
            case .unavailable(.deviceNotEligible):
                return "This device doesn't support Apple Intelligence."
            case .unavailable(.appleIntelligenceNotEnabled):
                return "Please enable Apple Intelligence in Settings to use Gravity AI."
            case .unavailable(.modelNotReady):
                return "The AI model is still downloading. Please try again in a few minutes."
            case .unavailable(_):
                return "Apple Intelligence is currently unavailable."
            @unknown default:
                return "Apple Intelligence is currently unavailable."
            }
        }
        return "This device doesn't support Apple Intelligence."
    }
}
