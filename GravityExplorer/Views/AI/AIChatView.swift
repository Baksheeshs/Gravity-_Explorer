import SwiftUI
import FoundationModels

// MARK: - AI Chat View
@available(iOS 26.0, *)
struct AIChatView: View {
    @StateObject private var viewModel = AIChatViewModel()
    @Namespace private var bottomID

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Theme.backgroundGradient.ignoresSafeArea()
                StarfieldView()

                if !viewModel.isModelAvailable {
                    unavailableView
                } else {
                    VStack(spacing: 0) {
                        // Header
                        chatHeader

                        // Messages or Welcome
                        if viewModel.messages.isEmpty {
                            welcomeSection
                        } else {
                            messageList
                        }

                        // Input bar
                        inputBar
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Unavailable View

    private var unavailableView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundColor(Theme.dimText)

            Text("Gravity AI Unavailable")
                .font(Theme.title(24))
                .foregroundColor(Theme.primaryText)

            Text(viewModel.unavailabilityMessage)
                .font(Theme.body(14))
                .foregroundColor(Theme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
    }

    // MARK: - Header

    private var chatHeader: some View {
        HStack(spacing: 12) {
            // AI Avatar
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Theme.cosmicCyan.opacity(0.4), Theme.starGlow.opacity(0.1)],
                            center: .center,
                            startRadius: 2,
                            endRadius: 20
                        )
                    )
                    .frame(width: 40, height: 40)

                Image(systemName: "brain.head.profile")
                    .font(.system(size: 20))
                    .foregroundColor(Theme.cosmicCyan)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Gravity AI")
                    .font(Theme.subtitle(18))
                    .foregroundColor(Theme.primaryText)

                HStack(spacing: 4) {
                    Circle()
                        .fill(Theme.auroraGreen)
                        .frame(width: 6, height: 6)
                    Text("Powered by Apple Intelligence")
                        .font(Theme.caption(11))
                        .foregroundColor(Theme.secondaryText)
                }
            }

            Spacer()

            // Clear chat button
            if !viewModel.messages.isEmpty {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        viewModel.clearChat()
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.secondaryText)
                        .padding(8)
                        .background(Circle().fill(Color.white.opacity(0.08)))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial.opacity(0.3))
                .ignoresSafeArea(edges: .top)
        )
    }

    // MARK: - Welcome Section

    private var welcomeSection: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                Spacer().frame(height: 40)

                // Large AI icon
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Theme.cosmicCyan.opacity(0.3), .clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 70
                            )
                        )
                        .frame(width: 120, height: 120)

                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Theme.starGlow, Theme.cosmicCyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(spacing: 8) {
                    Text("Gravity AI Assistant")
                        .font(Theme.title(26))
                        .foregroundColor(Theme.primaryText)

                    Text("Powered by Apple Intelligence.\nAsk me anything about gravity and space.")
                        .font(Theme.body(14))
                        .foregroundColor(Theme.secondaryText)
                        .multilineTextAlignment(.center)
                }

                // Suggested Questions
                VStack(alignment: .leading, spacing: 10) {
                    Text("SUGGESTED QUESTIONS")
                        .font(Theme.caption(11))
                        .foregroundColor(Theme.dimText)
                        .tracking(2)
                        .padding(.horizontal, 4)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(viewModel.suggestedQuestions.prefix(6), id: \.self) { question in
                            Button {
                                viewModel.sendSuggestedQuestion(question)
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "sparkle")
                                        .font(.system(size: 10))
                                        .foregroundColor(Theme.cosmicCyan)

                                    Text(question)
                                        .font(Theme.caption(12))
                                        .foregroundColor(Theme.primaryText)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .glassCard(cornerRadius: 14)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)

                Spacer()
            }
        }
    }

    // MARK: - Message List

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                    }

                    // Typing indicator
                    if viewModel.isThinking {
                        TypingIndicator()
                            .transition(.opacity.combined(with: .scale(scale: 0.8)))
                    }

                    // Invisible anchor for scrolling
                    Color.clear
                        .frame(height: 1)
                        .id("bottom")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .onChange(of: viewModel.messages.count) { _ in
                withAnimation(.easeOut(duration: 0.3)) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
            .onChange(of: viewModel.isThinking) { _ in
                withAnimation(.easeOut(duration: 0.3)) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
        }
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        HStack(spacing: 10) {
            // Text field
            HStack {
                TextField("Ask about gravity...", text: $viewModel.inputText)
                    .font(Theme.body(15))
                    .foregroundColor(Theme.primaryText)
                    .autocorrectionDisabled(false)
                    .submitLabel(.send)
                    .onSubmit {
                        viewModel.sendMessage()
                    }

                if !viewModel.inputText.isEmpty {
                    Button {
                        viewModel.inputText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Theme.dimText)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
            )

            // Send button
            Button {
                viewModel.sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(
                        viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty
                            ? Color.white.opacity(0.2)
                            : Theme.cosmicCyan
                    )
            }
            .disabled(viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isThinking)
            .animation(.easeInOut(duration: 0.2), value: viewModel.inputText.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial.opacity(0.4))
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - Message Bubble

@available(iOS 26.0, *)
struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 50)
                userBubble
            } else {
                aiBubble
                Spacer(minLength: 50)
            }
        }
    }

    private var userBubble: some View {
        Text(message.content)
            .font(Theme.body(14))
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Theme.starGlow.opacity(0.6), Theme.cosmicCyan.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
    }

    private var aiBubble: some View {
        HStack(alignment: .top, spacing: 8) {
            // AI Avatar
            Image(systemName: "brain.head.profile")
                .font(.system(size: 14))
                .foregroundColor(message.isError ? Theme.plasmaRed : Theme.cosmicCyan)
                .padding(6)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.08))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(formattedContent)
                    .font(Theme.body(14))
                    .foregroundColor(Theme.primaryText.opacity(0.95))
                    .textSelection(.enabled)

                Text(timeString)
                    .font(Theme.caption(10))
                    .foregroundColor(Theme.dimText)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .glassCard(cornerRadius: 18)
        }
    }

    private var formattedContent: AttributedString {
        if let attributed = try? AttributedString(markdown: message.content) {
            return attributed
        }
        return AttributedString(message.content)
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: message.timestamp)
    }
}

// MARK: - Typing Indicator

@available(iOS 26.0, *)
struct TypingIndicator: View {
    @State private var phase: Int = 0

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 14))
                .foregroundColor(Theme.cosmicCyan)
                .padding(6)
                .background(Circle().fill(Color.white.opacity(0.08)))

            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Theme.cosmicCyan.opacity(index == phase ? 1.0 : 0.3))
                        .frame(width: 7, height: 7)
                        .scaleEffect(index == phase ? 1.2 : 0.8)
                        .animation(.easeInOut(duration: 0.4), value: phase)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .glassCard(cornerRadius: 18)

            Spacer()
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { timer in
                phase = (phase + 1) % 3
            }
        }
    }
}
