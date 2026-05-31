import SwiftUI

// MARK: - Educational Overlay
struct EducationalOverlay: View {
    let title: String
    let description: String
    let icon: String
    var accentColor: Color = Theme.starGlow
    @Binding var isVisible: Bool

    var body: some View {
        if isVisible {
            ZStack {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.2)) {
                            isVisible = false
                        }
                    }
                    .transition(.opacity)

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(accentColor)

                        Text(title)
                            .font(Theme.subtitle(16))
                            .foregroundColor(Theme.primaryText)

                        Spacer()

                        Button {
                            withAnimation(.easeOut(duration: 0.2)) {
                                isVisible = false
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Theme.dimText)
                        }
                    }

                    Text(description)
                        .font(Theme.body(14))
                        .foregroundColor(Theme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(20)
                .glassCard(cornerRadius: 20)
                .padding(.horizontal, 24)
                .transition(.scale(scale: 0.95).combined(with: .opacity))
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(title). \(description)")
            }
            .zIndex(100)
        }
    }
}

// MARK: - Info Button (to toggle overlay)
struct InfoButton: View {
    var accentColor: Color = .white
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "info.circle")
                .font(.system(size: 20))
                .foregroundColor(.white)
        }
        .accessibilityLabel("Show information")
    }
}
