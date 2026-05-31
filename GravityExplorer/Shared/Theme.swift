import SwiftUI

// MARK: - Space Theme Colors & Styles
struct Theme {
    // Primary backgrounds
    static let deepSpace = Color(red: 0.04, green: 0.04, blue: 0.12)
    static let cosmicNavy = Color(red: 0.06, green: 0.08, blue: 0.20)
    static let nebulaPurple = Color(red: 0.15, green: 0.08, blue: 0.30)

    // Accent colors
    static let starGlow = Color(red: 0.55, green: 0.80, blue: 1.0)
    static let solarOrange = Color(red: 1.0, green: 0.60, blue: 0.20)
    static let auroraGreen = Color(red: 0.20, green: 0.90, blue: 0.60)
    static let plasmaRed = Color(red: 1.0, green: 0.30, blue: 0.40)
    static let cosmicCyan = Color(red: 0.0, green: 0.85, blue: 0.90)

    // Text
    static let primaryText = Color.white
    static let secondaryText = Color(white: 0.70)
    static let dimText = Color(white: 0.45)

    // Gradients
    static let cardGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.12),
            Color.white.opacity(0.04)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let backgroundGradient = LinearGradient(
        colors: [deepSpace, cosmicNavy, nebulaPurple.opacity(0.3)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let accentGradient = LinearGradient(
        colors: [starGlow, cosmicCyan],
        startPoint: .leading,
        endPoint: .trailing
    )

    // Fonts
    static func title(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    static func subtitle(_ size: CGFloat = 18) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    static func body(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }

    static func caption(_ size: CGFloat = 12) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
}

// MARK: - Glassmorphic Card Modifier
struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial.opacity(0.5))
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Theme.cardGradient)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.25), Color.white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius))
    }
}
