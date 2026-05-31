import SwiftUI

// MARK: - Module Card
struct ModuleCardView: View {
    let module: ModuleInfo
    let index: Int
    @State private var isPressed = false
    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(module.accentColor.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: module.icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(module.accentColor)
                }

                Spacer()

                Text("0\(module.id)")
                    .font(Theme.caption(11))
                    .foregroundColor(Theme.dimText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(module.title)
                    .font(Theme.subtitle(16))
                    .foregroundColor(Theme.primaryText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                Text(module.subtitle)
                    .font(Theme.caption(12))
                    .foregroundColor(Theme.secondaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            HStack {
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(module.accentColor.opacity(0.7))
            }
        }
        .padding(16)
        .frame(height: 170)
        .glassCard()
        .shadow(color: module.accentColor.opacity(0.15), radius: 12, x: 0, y: 6)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 30)
        .animation(
            .spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.08),
            value: appeared
        )
        .onAppear { appeared = true }
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = pressing
            }
        }, perform: {})
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(module.title). \(module.subtitle)")
        .accessibilityHint("Double tap to explore this module")
    }
}
