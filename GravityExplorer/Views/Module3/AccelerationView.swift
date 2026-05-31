import SwiftUI
import SpriteKit

// MARK: - Module 3: Acceleration Due to Gravity
struct AccelerationView: View {
    @State private var isVacuum = false
    @State private var showInfo = false
    @State private var fallTime: Double = 0
    @State private var velocity: Double = 0
    @State private var isRunning = false
    @State private var velocityData: [(time: Double, velocity: Double)] = []
    @State private var dropScene: DropExperimentScene? = nil
    @State private var sceneId = UUID()

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 12) {
                // Toggle
                HStack {
                    Toggle(isOn: $isVacuum) {
                        HStack(spacing: 6) {
                            Image(systemName: isVacuum ? "circle.dashed" : "wind")
                                .foregroundColor(Theme.auroraGreen)
                            Text(isVacuum ? "Vacuum (No Air)" : "With Air Resistance")
                                .font(Theme.body(14))
                                .foregroundColor(.white)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Theme.auroraGreen))
                    .onChange(of: isVacuum) { _, _ in
                        resetExperiment()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)

                // SpriteKit Scene
                SpriteView(scene: currentScene())
                    .id(sceneId)
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16)

                // Stats
                HStack(spacing: 16) {
                    statCard(label: "Time", value: String(format: "%.2f", fallTime), unit: "s", color: Theme.starGlow)
                    statCard(label: "Velocity", value: String(format: "%.1f", velocity), unit: "m/s", color: Theme.auroraGreen)
                    statCard(label: "g", value: "9.81", unit: "m/s²", color: Theme.solarOrange)
                }
                .padding(.horizontal, 16)

                // Velocity-Time Graph
                VStack(alignment: .leading, spacing: 8) {
                    Text("Velocity vs Time")
                        .font(Theme.subtitle(14))
                        .foregroundColor(Theme.secondaryText)

                    velocityGraph
                        .frame(height: 120)
                }
                .padding(14)
                .glassCard(cornerRadius: 14)
                .padding(.horizontal, 16)

                // Controls
                HStack(spacing: 12) {
                    Button {
                        startExperiment()
                    } label: {
                        HStack {
                            Image(systemName: isRunning ? "pause.fill" : "play.fill")
                            Text(isRunning ? "Falling..." : "Drop")
                        }
                        .font(Theme.subtitle(15))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.auroraGreen.opacity(isRunning ? 0.3 : 0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(isRunning)

                    Button {
                        resetExperiment()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(Theme.subtitle(15))
                            .foregroundColor(.white)
                            .padding(14)
                            .background(Color.white.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }

            EducationalOverlay(
                title: "Free Fall Acceleration",
                description: "In a vacuum, all objects fall at the same rate: g ≈ 9.8 m/s². Air resistance makes lighter objects (like feathers) fall slower. Velocity increases linearly with time!",
                icon: "arrow.down.to.line.compact",
                accentColor: Theme.auroraGreen,
                isVisible: $showInfo
            )
        }
        .navigationTitle("Acceleration")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                InfoButton(accentColor: Theme.auroraGreen) {
                    withAnimation { showInfo.toggle() }
                }
            }
        }
    }

    private func statCard(label: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(Theme.caption(11))
                .foregroundColor(Theme.dimText)
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            Text(unit)
                .font(Theme.caption(10))
                .foregroundColor(Theme.dimText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .glassCard(cornerRadius: 12)
    }

    // MARK: - Velocity Graph
    private var velocityGraph: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let maxTime: Double = 5.0
            let maxVel: Double = 20.0

            ZStack {
                // Grid lines
                ForEach(0..<4) { i in
                    let y = h - (h * Double(i) / 3.0)
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: w, y: y))
                    }
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
                }

                // Data line
                if velocityData.count > 1 {
                    Path { path in
                        for (i, point) in velocityData.enumerated() {
                            let x = (point.time / maxTime) * w
                            let y = h - (point.velocity / maxVel) * h
                            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                            else { path.addLine(to: CGPoint(x: x, y: y)) }
                        }
                    }
                    .stroke(Theme.auroraGreen, lineWidth: 2)
                }

                // Labels
                VStack {
                    HStack {
                        Text("v (m/s)")
                            .font(.system(size: 9))
                            .foregroundColor(Theme.dimText)
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Text("t (s)")
                            .font(.system(size: 9))
                            .foregroundColor(Theme.dimText)
                    }
                }
            }
        }
    }

    private func currentScene() -> DropExperimentScene {
        if let scene = dropScene {
            return scene
        }
        let scene = makeDropScene()
        DispatchQueue.main.async { dropScene = scene }
        return scene
    }

    private func makeDropScene() -> DropExperimentScene {
        let scene = DropExperimentScene(size: CGSize(width: 400, height: 300))
        scene.isVacuum = isVacuum
        scene.onUpdate = { time, vel in
            DispatchQueue.main.async {
                fallTime = time
                velocity = vel
                velocityData.append((time: time, velocity: vel))
            }
        }
        scene.onComplete = {
            DispatchQueue.main.async {
                isRunning = false
            }
        }
        return scene
    }

    private func startExperiment() {
        isRunning = true
        velocityData = []
        fallTime = 0
        velocity = 0
        // Tell the existing scene to drop — don't recreate it
        dropScene?.triggerDrop()
        HapticManager.shared.forceApplied()
    }

    private func resetExperiment() {
        isRunning = false
        fallTime = 0
        velocity = 0
        velocityData = []
        dropScene = nil
        sceneId = UUID()
    }
}

// MARK: - Drop Experiment SpriteKit Scene
class DropExperimentScene: SKScene, @preconcurrency SKPhysicsContactDelegate {
    var isVacuum = false
    var onUpdate: ((Double, Double) -> Void)?
    var onComplete: (() -> Void)?

    private var ball: SKShapeNode?
    private var feather: SKShapeNode?
    private var startTime: TimeInterval?
    private var hasLanded = false
    private var hasDropped = false

    // Slower gravity so the user can observe the difference
    private let gravityScale: CGFloat = 2.0

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.04, green: 0.04, blue: 0.12, alpha: 1)
        scaleMode = .aspectFill
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.81 * gravityScale)
        physicsWorld.contactDelegate = self

        setupScene()
    }

    /// Called from SwiftUI when user taps "Drop"
    func triggerDrop() {
        guard !hasDropped else { return }
        hasDropped = true
        ball?.physicsBody?.isDynamic = true
        feather?.physicsBody?.isDynamic = true
        childNode(withName: "tapHint")?.removeFromParent()
    }

    private func setupScene() {
        // Ground
        let ground = SKShapeNode(rectOf: CGSize(width: size.width, height: 6))
        ground.fillColor = UIColor(red: 0.2, green: 0.9, blue: 0.6, alpha: 0.4)
        ground.strokeColor = .clear
        ground.position = CGPoint(x: size.width / 2, y: 25)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: 6))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = 0x1
        ground.physicsBody?.contactTestBitMask = 0x2
        addChild(ground)

        // Ball (heavy) — starts FROZEN
        let b = SKShapeNode(circleOfRadius: 18)
        b.fillColor = UIColor(red: 1, green: 0.3, blue: 0.4, alpha: 1)
        b.strokeColor = UIColor(red: 1, green: 0.3, blue: 0.4, alpha: 0.4)
        b.glowWidth = 3
        b.position = CGPoint(x: size.width * 0.35, y: size.height - 50)
        b.physicsBody = SKPhysicsBody(circleOfRadius: 18)
        b.physicsBody?.isDynamic = false   // frozen until drop
        b.physicsBody?.mass = 5.0
        b.physicsBody?.linearDamping = isVacuum ? 0 : 0.1
        b.physicsBody?.restitution = 0.2
        b.physicsBody?.categoryBitMask = 0x2
        b.physicsBody?.contactTestBitMask = 0x1
        addChild(b)
        ball = b

        let ballLabel = SKLabelNode(text: "🔴 Ball")
        ballLabel.fontSize = 13
        ballLabel.fontColor = UIColor(red: 1, green: 0.3, blue: 0.4, alpha: 1)
        ballLabel.position = CGPoint(x: b.position.x, y: size.height - 20)
        addChild(ballLabel)

        // Feather (light) — starts FROZEN
        let f = SKShapeNode(ellipseOf: CGSize(width: 30, height: 10))
        f.fillColor = UIColor.white
        f.strokeColor = UIColor.white.withAlphaComponent(0.4)
        f.glowWidth = 2
        f.position = CGPoint(x: size.width * 0.65, y: size.height - 50)
        f.physicsBody = SKPhysicsBody(circleOfRadius: 12)
        f.physicsBody?.isDynamic = false   // frozen until drop
        f.physicsBody?.mass = 0.01
        f.physicsBody?.linearDamping = isVacuum ? 0 : 8.0  // stronger air drag for visible difference
        f.physicsBody?.restitution = 0.1
        f.physicsBody?.categoryBitMask = 0x2
        f.physicsBody?.contactTestBitMask = 0x1
        addChild(f)
        feather = f

        let featherLabel = SKLabelNode(text: "🪶 Feather")
        featherLabel.fontSize = 13
        featherLabel.fontColor = .white
        featherLabel.position = CGPoint(x: f.position.x, y: size.height - 20)
        addChild(featherLabel)

        // Hint label
        let hint = SKLabelNode(text: "Press Drop to begin")
        hint.fontSize = 14
        hint.fontColor = UIColor.white.withAlphaComponent(0.4)
        hint.position = CGPoint(x: size.width / 2, y: size.height / 2)
        hint.name = "tapHint"
        addChild(hint)

        // Mode label
        let modeLabel = SKLabelNode(text: isVacuum ? "🔬 Vacuum" : "💨 With Air")
        modeLabel.fontSize = 14
        modeLabel.fontColor = UIColor(red: 0.55, green: 0.8, blue: 1.0, alpha: 1)
        modeLabel.position = CGPoint(x: size.width / 2, y: 45)
        addChild(modeLabel)

        startTime = nil
        hasDropped = false
        hasLanded = false
    }

    override func update(_ currentTime: TimeInterval) {
        guard hasDropped else { return }

        if startTime == nil {
            startTime = currentTime
        }

        guard let start = startTime, !hasLanded else { return }

        let elapsed = currentTime - start
        let vel = abs(ball?.physicsBody?.velocity.dy ?? 0) / gravityScale

        onUpdate?(elapsed, Double(vel))
    }

    func didBegin(_ contact: SKPhysicsContact) {
        guard !hasLanded else { return }
        hasLanded = true
        onComplete?()
    }
}
