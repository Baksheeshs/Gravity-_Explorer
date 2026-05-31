import SwiftUI
import SpriteKit

// MARK: - Module 2: Capital G vs Small g
struct GvsGView: View {
    @State private var selectedTab = 0
    @State private var showInfo = false
    @State private var mass1: Double = 100.0
    @State private var mass2: Double = 50.0
    @State private var distance: Double = 5.0
    @State private var selectedPlanet: PlanetData = planets[0]
    @State private var forceScene: GravitationalForceScene = {
        let scene = GravitationalForceScene(size: CGSize(width: 400, height: 220))
        scene.mass1Value = 100
        scene.mass2Value = 50
        scene.distanceValue = 5
        return scene
    }()

    private var gravitationalForce: Double {
        universalG * mass1 * mass2 / (distance * distance)
    }

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                // Tab selector
                Picker("Mode", selection: $selectedTab) {
                    Text("Capital G").tag(0)
                    Text("Small g").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 8)

                if selectedTab == 0 {
                    capitalGPanel
                } else {
                    smallGPanel
                }
            }

            EducationalOverlay(
                title: selectedTab == 0 ? "Universal Constant G" : "Local Acceleration g",
                description: selectedTab == 0
                    ? "G = 6.674 × 10⁻¹¹ N⋅m²/kg² is the same everywhere in the universe. It determines the strength of gravitational attraction between any two masses."
                    : "Small g varies by location. It's the acceleration objects experience due to a planet's gravity. On Earth, g ≈ 9.81 m/s².",
                icon: "scalemass.fill",
                accentColor: Theme.solarOrange,
                isVisible: $showInfo
            )
        }
        .navigationTitle("G vs g")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                InfoButton(accentColor: Theme.solarOrange) {
                    withAnimation { showInfo.toggle() }
                }
            }
        }
    }

    // MARK: - Capital G Panel
    private var capitalGPanel: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Visualization – persistent scene, no .id() modifier
                SpriteView(scene: forceScene)
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16)

                // Formula display
                VStack(spacing: 8) {
                    Text("F = G × m₁ × m₂ / r²")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(Theme.solarOrange)

                    Text("F = \(gravitationalForce, specifier: "%.2e") N")
                        .font(Theme.subtitle(16))
                        .foregroundColor(.white)
                }
                .padding(16)
                .glassCard(cornerRadius: 14)
                .padding(.horizontal, 16)

                // Controls
                VStack(spacing: 14) {
                    sliderControl(label: "Mass 1", value: $mass1, range: 1...1000, unit: "kg", color: Theme.plasmaRed)
                    sliderControl(label: "Mass 2", value: $mass2, range: 1...1000, unit: "kg", color: Theme.auroraGreen)
                    sliderControl(label: "Distance", value: $distance, range: 1...20, unit: "m", color: Theme.starGlow)
                }
                .padding(16)
                .glassCard(cornerRadius: 16)
                .padding(.horizontal, 16)

                // Key fact
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                    Text("G is constant – it never changes no matter where you are!")
                        .font(Theme.body(14))
                        .foregroundColor(Theme.secondaryText)
                }
                .padding(14)
                .glassCard(cornerRadius: 12)
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
            .padding(.top, 12)
        }
        .onChange(of: mass1) { _, newValue in
            forceScene.mass1Value = newValue
            forceScene.refreshScene()
        }
        .onChange(of: mass2) { _, newValue in
            forceScene.mass2Value = newValue
            forceScene.refreshScene()
        }
        .onChange(of: distance) { _, newValue in
            forceScene.distanceValue = newValue
            forceScene.refreshScene()
        }
    }

    // MARK: - Small g Panel
    private var smallGPanel: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Planet selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(planets) { planet in
                            planetChip(planet)
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // Drop animation
                SpriteView(scene: makePlanetDropScene())
                    .id("drop-\(selectedPlanet.id)")
                    .frame(height: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16)

                // Info card
                VStack(spacing: 8) {
                    Text(selectedPlanet.name)
                        .font(Theme.title(24))
                        .foregroundColor(selectedPlanet.color)

                    HStack(spacing: 20) {
                        VStack {
                            Text("g")
                                .font(Theme.caption(12))
                                .foregroundColor(Theme.dimText)
                            Text("\(selectedPlanet.g, specifier: "%.2f")")
                                .font(.system(size: 28, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                            Text("m/s²")
                                .font(Theme.caption(11))
                                .foregroundColor(Theme.dimText)
                        }

                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 1, height: 50)

                        VStack {
                            Text("G")
                                .font(Theme.caption(12))
                                .foregroundColor(Theme.dimText)
                            Text("6.674")
                                .font(.system(size: 28, weight: .bold, design: .monospaced))
                                .foregroundColor(Theme.solarOrange)
                            Text("×10⁻¹¹")
                                .font(Theme.caption(11))
                                .foregroundColor(Theme.dimText)
                        }
                    }
                }
                .padding(16)
                .glassCard(cornerRadius: 16)
                .padding(.horizontal, 16)

                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                    Text("g changes between planets, but G stays the same everywhere!")
                        .font(Theme.body(14))
                        .foregroundColor(Theme.secondaryText)
                }
                .padding(14)
                .glassCard(cornerRadius: 12)
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
            .padding(.top, 12)
        }
    }

    private func planetChip(_ planet: PlanetData) -> some View {
        Button {
            withAnimation { selectedPlanet = planet }
            HapticManager.shared.selection()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: planet.icon)
                    .font(.system(size: 20))
                Text(planet.name)
                    .font(Theme.caption(11))
            }
            .foregroundColor(selectedPlanet == planet ? .white : Theme.secondaryText)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                selectedPlanet == planet
                    ? AnyShapeStyle(planet.color.opacity(0.3))
                    : AnyShapeStyle(Color.white.opacity(0.06))
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedPlanet == planet ? planet.color.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
        .accessibilityLabel("\(planet.name), g equals \(planet.g) meters per second squared")
    }

    private func sliderControl(label: String, value: Binding<Double>, range: ClosedRange<Double>, unit: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack {
                Text(label)
                    .font(Theme.body(14))
                    .foregroundColor(Theme.secondaryText)
                Spacer()
                Text("\(value.wrappedValue, specifier: "%.1f") \(unit)")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(color)
            }
            Slider(value: value, in: range)
                .tint(color)
        }
    }

    private func makePlanetDropScene() -> SKScene {
        let scene = PlanetDropScene(size: CGSize(width: 400, height: 260))
        scene.planetG = selectedPlanet.g
        scene.planetColor = UIColor(selectedPlanet.color)
        return scene
    }
}

// MARK: - Gravitational Force SpriteKit Scene
class GravitationalForceScene: SKScene {
    var mass1Value: Double = 100
    var mass2Value: Double = 50
    var distanceValue: Double = 5

    private var sphere1: SKShapeNode?
    private var sphere2: SKShapeNode?

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.06, green: 0.08, blue: 0.20, alpha: 1)
        scaleMode = .aspectFill
        drawScene()
        animateBalls()
    }

    /// Called from SwiftUI onChange to update the scene in-place without flicker.
    func refreshScene() {
        drawScene()
        animateBalls()
    }

    private func drawScene() {
        removeAllChildren()

        let centerY = size.height / 2
        let margin: CGFloat = 60
        let maxDist = size.width - margin * 2

        let radius1 = CGFloat(min(max(mass1Value / 20, 15), 50))
        let radius2 = CGFloat(min(max(mass2Value / 20, 15), 50))

        let normalizedDist = CGFloat(distanceValue / 20.0) * maxDist
        let x1 = size.width / 2 - normalizedDist / 2
        let x2 = size.width / 2 + normalizedDist / 2

        // Mass 1
        let s1 = SKShapeNode(circleOfRadius: radius1)
        s1.fillColor = UIColor(red: 1, green: 0.3, blue: 0.4, alpha: 1)
        s1.strokeColor = UIColor(red: 1, green: 0.3, blue: 0.4, alpha: 0.5)
        s1.glowWidth = 3
        s1.position = CGPoint(x: x1, y: centerY)
        addChild(s1)
        sphere1 = s1

        let label1 = SKLabelNode(text: "m₁ = \(String(format: "%.0f", mass1Value)) kg")
        label1.fontSize = 12
        label1.fontColor = .white
        label1.position = CGPoint(x: x1, y: centerY - radius1 - 18)
        addChild(label1)

        // Mass 2
        let s2 = SKShapeNode(circleOfRadius: radius2)
        s2.fillColor = UIColor(red: 0.2, green: 0.9, blue: 0.6, alpha: 1)
        s2.strokeColor = UIColor(red: 0.2, green: 0.9, blue: 0.6, alpha: 0.5)
        s2.glowWidth = 3
        s2.position = CGPoint(x: x2, y: centerY)
        addChild(s2)
        sphere2 = s2

        let label2 = SKLabelNode(text: "m₂ = \(String(format: "%.0f", mass2Value)) kg")
        label2.fontSize = 12
        label2.fontColor = .white
        label2.position = CGPoint(x: x2, y: centerY - radius2 - 18)
        addChild(label2)

        // Force arrows — both directions to show mutual attraction
        let force = 6.674e-11 * mass1Value * mass2Value / (distanceValue * distanceValue)
        let arrowLen = min(CGFloat(force / (6.674e-11 * 1000 * 1000 / 1)) * (normalizedDist * 0.3), normalizedDist * 0.4)
        
        // Arrow from m1 toward m2
        drawArrow(from: CGPoint(x: x1 + radius1 + 5, y: centerY),
                  to: CGPoint(x: x1 + radius1 + 5 + arrowLen, y: centerY),
                  color: UIColor(red: 1, green: 1, blue: 0.3, alpha: 0.8))
        
        // Arrow from m2 toward m1
        drawArrow(from: CGPoint(x: x2 - radius2 - 5, y: centerY),
                  to: CGPoint(x: x2 - radius2 - 5 - arrowLen, y: centerY),
                  color: UIColor(red: 1, green: 1, blue: 0.3, alpha: 0.8))

        // Distance label
        let distLabel = SKLabelNode(text: "r = \(String(format: "%.1f", distanceValue)) m")
        distLabel.fontSize = 12
        distLabel.fontColor = UIColor(red: 0.55, green: 0.8, blue: 1.0, alpha: 1)
        distLabel.position = CGPoint(x: size.width / 2, y: centerY + max(radius1, radius2) + 20)
        addChild(distLabel)
    }

    private func animateBalls() {
        // Pulse animation — stronger force = faster pulse
        let force = 6.674e-11 * mass1Value * mass2Value / (distanceValue * distanceValue)
        let normalizedForce = min(force / (6.674e-11 * 500 * 500 / 25), 1.0)
        let pulseDuration = max(0.3, 1.5 - normalizedForce * 1.2)
        
        let scaleUp = SKAction.scale(to: 1.15, duration: pulseDuration)
        let scaleDown = SKAction.scale(to: 1.0, duration: pulseDuration)
        scaleUp.timingMode = .easeInEaseOut
        scaleDown.timingMode = .easeInEaseOut
        let pulse = SKAction.repeatForever(SKAction.sequence([scaleUp, scaleDown]))
        
        sphere1?.run(pulse)
        sphere2?.run(pulse)
        
        // Wobble toward each other to show attraction
        let wobbleAmount = CGFloat(min(normalizedForce * 8, 6))
        let wobbleDuration = max(0.4, 1.5 - normalizedForce * 1.0)
        
        let moveRight = SKAction.moveBy(x: wobbleAmount, y: 0, duration: wobbleDuration)
        let moveLeft = SKAction.moveBy(x: -wobbleAmount, y: 0, duration: wobbleDuration)
        moveRight.timingMode = .easeInEaseOut
        moveLeft.timingMode = .easeInEaseOut
        
        sphere1?.run(SKAction.repeatForever(SKAction.sequence([moveRight, moveLeft])))
        sphere2?.run(SKAction.repeatForever(SKAction.sequence([moveLeft, moveRight])))
    }

    private func drawArrow(from start: CGPoint, to end: CGPoint, color: UIColor) {
        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)
        let line = SKShapeNode(path: path)
        line.strokeColor = color
        line.lineWidth = 2
        line.glowWidth = 1
        addChild(line)

        // Arrowhead
        let arrowSize: CGFloat = 8
        let angle = atan2(end.y - start.y, end.x - start.x)
        let arrowPath = CGMutablePath()
        arrowPath.move(to: end)
        arrowPath.addLine(to: CGPoint(
            x: end.x - arrowSize * cos(angle - .pi / 6),
            y: end.y - arrowSize * sin(angle - .pi / 6)
        ))
        arrowPath.addLine(to: CGPoint(
            x: end.x - arrowSize * cos(angle + .pi / 6),
            y: end.y - arrowSize * sin(angle + .pi / 6)
        ))
        arrowPath.closeSubpath()
        let arrow = SKShapeNode(path: arrowPath)
        arrow.fillColor = color
        arrow.strokeColor = .clear
        addChild(arrow)
    }
}

// MARK: - Planet Drop Scene
class PlanetDropScene: SKScene {
    var planetG: Double = 9.81
    var planetColor: UIColor = .blue
    private var ball: SKShapeNode?
    private var isDropping = false

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.04, green: 0.04, blue: 0.12, alpha: 1)
        scaleMode = .aspectFill
        physicsWorld.gravity = CGVector(dx: 0, dy: -planetG * 10)

        setupScene()
    }

    private func setupScene() {
        removeAllChildren()

        // Ground
        let ground = SKShapeNode(rectOf: CGSize(width: size.width, height: 4))
        ground.fillColor = planetColor.withAlphaComponent(0.5)
        ground.strokeColor = .clear
        ground.position = CGPoint(x: size.width / 2, y: 40)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: 4))
        ground.physicsBody?.isDynamic = false
        addChild(ground)

        // Ball
        let b = SKShapeNode(circleOfRadius: 15)
        b.fillColor = planetColor
        b.strokeColor = planetColor.withAlphaComponent(0.5)
        b.glowWidth = 4
        b.position = CGPoint(x: size.width / 2, y: size.height - 50)
        b.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        b.physicsBody?.isDynamic = false
        b.physicsBody?.restitution = 0.4
        addChild(b)
        ball = b

        // Tap instruction
        let tapLabel = SKLabelNode(text: "Tap to Drop")
        tapLabel.fontSize = 14
        tapLabel.fontColor = UIColor.white.withAlphaComponent(0.5)
        tapLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        tapLabel.name = "tapLabel"
        addChild(tapLabel)

        // g value label
        let gLabel = SKLabelNode(text: "g = \(String(format: "%.2f", planetG)) m/s²")
        gLabel.fontSize = 16
        gLabel.fontColor = planetColor
        gLabel.position = CGPoint(x: size.width / 2, y: size.height - 25)
        addChild(gLabel)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isDropping else {
            // Reset
            isDropping = false
            physicsWorld.gravity = CGVector(dx: 0, dy: -planetG * 10)
            setupScene()
            return
        }

        isDropping = true
        ball?.physicsBody?.isDynamic = true
        childNode(withName: "tapLabel")?.removeFromParent()
    }
}
