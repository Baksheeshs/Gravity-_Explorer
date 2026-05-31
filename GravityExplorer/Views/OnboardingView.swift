import SwiftUI

// MARK: - Onboarding Data
struct OnboardingPage: Identifiable {
    let id: Int
    let icon: String
    let title: String
    let subtitle: String
    let accentColor: Color
}

private let onboardingPages: [OnboardingPage] = [
    OnboardingPage(
        id: 0,
        icon: "globe.americas.fill",
        title: "Welcome to\nGravity Explorer",
        subtitle: "Discover the invisible force that shapes the entire universe",
        accentColor: Theme.starGlow
    ),
    OnboardingPage(
        id: 1,
        icon: "books.vertical.fill",
        title: "6 Interactive\nModules",
        subtitle: "Learn everything from free fall to planet gravity through hands-on experiments",
        accentColor: Theme.auroraGreen
    ),
    OnboardingPage(
        id: 2,
        icon: "sun.dust.fill",
        title: "3D Solar System\nSandbox",
        subtitle: "Build and explore your own solar system with real physics",
        accentColor: Theme.solarOrange
    ),
    OnboardingPage(
        id: 3,
        icon: "rocket.fill",
        title: "Ready to\nExplore?",
        subtitle: "Your journey through gravity starts now",
        accentColor: Theme.cosmicCyan
    ),
]

// MARK: - Onboarding View
struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            // Deep space background
            Theme.backgroundGradient.ignoresSafeArea()
            StarfieldView()

            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(onboardingPages) { page in
                        OnboardingPageView(
                            page: page,
                            isActive: currentPage == page.id,
                            isLastPage: page.id == onboardingPages.count - 1,
                            onGetStarted: {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    hasSeenOnboarding = true
                                }
                            }
                        )
                        .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                // Custom page indicator + controls
                bottomControls
                    .padding(.bottom, 50)
            }
        }
    }

    // MARK: - Bottom Controls
    private var bottomControls: some View {
        VStack(spacing: 24) {
            // Custom dot indicator
            HStack(spacing: 10) {
                ForEach(onboardingPages) { page in
                    Capsule()
                        .fill(
                            currentPage == page.id
                                ? page.accentColor
                                : Color.white.opacity(0.25)
                        )
                        .frame(
                            width: currentPage == page.id ? 28 : 8,
                            height: 8
                        )
                        .shadow(
                            color: currentPage == page.id
                                ? page.accentColor.opacity(0.6) : .clear,
                            radius: 6
                        )
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
                }
            }

            // Skip / Next buttons (hidden on last page, where CTA is shown inline)
            if currentPage < onboardingPages.count - 1 {
                HStack {
                    Button {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            hasSeenOnboarding = true
                        }
                    } label: {
                        Text("Skip")
                            .font(Theme.body(15))
                            .foregroundColor(Theme.dimText)
                    }

                    Spacer()

                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            currentPage += 1
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text("Next")
                                .font(Theme.subtitle(16))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            onboardingPages[currentPage].accentColor,
                                            onboardingPages[currentPage].accentColor.opacity(0.6)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(
                            color: onboardingPages[currentPage].accentColor.opacity(0.4),
                            radius: 12, y: 4
                        )
                    }
                }
                .padding(.horizontal, 32)
                .transition(.opacity)
            }
        }
    }
}

// MARK: - Single Onboarding Page
struct OnboardingPageView: View {
    let page: OnboardingPage
    let isActive: Bool
    let isLastPage: Bool
    let onGetStarted: () -> Void

    @State private var iconFloat = false
    @State private var contentAppeared = false
    @State private var ringRotation: Double = 0
    @State private var buttonPulse = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Animated icon area
            ZStack {
                // Outer glow rings
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(
                            page.accentColor.opacity(0.08 + Double(i) * 0.04),
                            lineWidth: 1.5
                        )
                        .frame(
                            width: CGFloat(140 + i * 40),
                            height: CGFloat(140 + i * 40)
                        )
                        .rotationEffect(.degrees(ringRotation + Double(i * 30)))
                }

                // Orbiting dot
                Circle()
                    .fill(page.accentColor)
                    .frame(width: 6, height: 6)
                    .shadow(color: page.accentColor.opacity(0.8), radius: 4)
                    .offset(y: -80)
                    .rotationEffect(.degrees(ringRotation))

                // Inner glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                page.accentColor.opacity(0.3),
                                page.accentColor.opacity(0.05),
                                .clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 70
                        )
                    )
                    .frame(width: 140, height: 140)
                    .blur(radius: 10)

                // Icon
                Image(systemName: page.icon)
                    .font(.system(size: 54, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [page.accentColor, page.accentColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: page.accentColor.opacity(0.5), radius: 12)
            }
            .offset(y: iconFloat ? -8 : 8)
            .animation(
                .easeInOut(duration: 2.5).repeatForever(autoreverses: true),
                value: iconFloat
            )

            // Text content
            VStack(spacing: 14) {
                Text(page.title)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(contentAppeared ? 1 : 0)
                    .offset(y: contentAppeared ? 0 : 20)

                Text(page.subtitle)
                    .font(Theme.body(16))
                    .foregroundColor(Theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(contentAppeared ? 1 : 0)
                    .offset(y: contentAppeared ? 0 : 15)
                    .animation(
                        .easeOut(duration: 0.6).delay(0.15),
                        value: contentAppeared
                    )
            }

            // CTA button on last page
            if isLastPage {
                Spacer().frame(height: 10)

                Button(action: onGetStarted) {
                    ZStack {
                        // Pulsing glow ring behind button
                        Capsule()
                            .stroke(page.accentColor.opacity(buttonPulse ? 0.5 : 0.15), lineWidth: 2)
                            .frame(width: 230, height: 58)
                            .scaleEffect(buttonPulse ? 1.12 : 1.0)
                            .animation(
                                .easeInOut(duration: 1.4).repeatForever(autoreverses: true),
                                value: buttonPulse
                            )

                        Text("Get Started")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 220, height: 52)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                page.accentColor,
                                                page.accentColor.opacity(0.6)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .clipShape(Capsule())
                            .shadow(
                                color: page.accentColor.opacity(0.5),
                                radius: 16, y: 6
                            )
                    }
                }
                .opacity(contentAppeared ? 1 : 0)
                .offset(y: contentAppeared ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.3), value: contentAppeared)
            }

            Spacer()
            Spacer()
        }
        .onAppear {
            iconFloat = true
            ringRotation = 360
            buttonPulse = true
            // Stagger the text appearance
            withAnimation(.easeOut(duration: 0.5)) {
                contentAppeared = true
            }
        }
        .onChange(of: isActive) { newVal in
            if newVal {
                contentAppeared = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        contentAppeared = true
                    }
                }
            }
        }
        .animation(
            .linear(duration: 12).repeatForever(autoreverses: false),
            value: ringRotation
        )
    }
}
