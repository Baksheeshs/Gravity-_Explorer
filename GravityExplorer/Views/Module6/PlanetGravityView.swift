import SwiftUI
import SceneKit

// MARK: - Module 6: Gravity Across Planets
struct PlanetGravityView: View {
    @State private var selectedPlanet = planets[0]
    @State private var showInfo = false
    @State private var jumpHeight: Double = 0
    @State private var isJumping = false
    @State private var sceneController = PlanetJumpSceneController()

    private let jumpVelocity: Double = 5.0 // m/s initial jump velocity

    private func calculateJumpHeight(g: Double) -> Double {
        guard g > 0 else { return 0 }
        return (jumpVelocity * jumpVelocity) / (2 * g)
    }

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                // Planet selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(planets) { planet in
                            planetButton(planet)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }

                // SceneKit View
                SceneView(
                    scene: sceneController.scene,
                    pointOfView: sceneController.cameraNode,
                    options: [.autoenablesDefaultLighting]
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 12)
                .onTapGesture {
                    if !isJumping {
                        isJumping = true
                        jumpHeight = calculateJumpHeight(g: selectedPlanet.g)
                        sceneController.jump(height: Float(jumpHeight))
                        HapticManager.shared.forceApplied(intensity: CGFloat(selectedPlanet.g / 25.0))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            isJumping = false
                        }
                    }
                }

                // Stats
                VStack(spacing: 12) {
                    HStack {
                        Text(selectedPlanet.name)
                            .font(Theme.title(22))
                            .foregroundColor(selectedPlanet.color)
                        Spacer()
                        Button {
                            if !isJumping {
                                isJumping = true
                                jumpHeight = calculateJumpHeight(g: selectedPlanet.g)
                                sceneController.jump(height: Float(jumpHeight))
                                HapticManager.shared.forceApplied(intensity: CGFloat(selectedPlanet.g / 25.0))
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    isJumping = false
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.up.circle.fill")
                                Text("Jump!")
                            }
                            .font(Theme.subtitle(14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(selectedPlanet.color.opacity(isJumping ? 0.3 : 0.7))
                            .clipShape(Capsule())
                        }
                        .disabled(isJumping)
                    }

                    // Gravity stats
                    HStack(spacing: 16) {
                        statBox(label: "Gravity", value: String(format: "%.2f", selectedPlanet.g), unit: "m/s²", color: selectedPlanet.color)
                        statBox(label: "Jump Height", value: String(format: "%.2f", calculateJumpHeight(g: selectedPlanet.g)), unit: "m", color: Theme.auroraGreen)
                    }

                    // Comparison bar chart
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Jump Height Comparison")
                            .font(Theme.caption(12))
                            .foregroundColor(Theme.dimText)

                        ForEach(planets) { planet in
                            let height = calculateJumpHeight(g: planet.g)
                            let maxHeight = calculateJumpHeight(g: planets.min(by: { $0.g < $1.g })!.g)

                            HStack(spacing: 8) {
                                Text(planet.name)
                                    .font(Theme.caption(10))
                                    .foregroundColor(planet == selectedPlanet ? .white : Theme.dimText)
                                    .frame(width: 50, alignment: .trailing)

                                GeometryReader { geo in
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(planet == selectedPlanet ? planet.color : planet.color.opacity(0.3))
                                        .frame(width: geo.size.width * CGFloat(height / maxHeight))
                                }
                                .frame(height: 12)

                                Text(String(format: "%.1fm", height))
                                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                    .foregroundColor(planet == selectedPlanet ? planet.color : Theme.dimText)
                                    .frame(width: 35, alignment: .leading)
                            }
                        }
                    }
                }
                .padding(16)
                .glassCard(cornerRadius: 16)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }

            EducationalOverlay(
                title: "Gravity Across Worlds",
                description: "Each planet has different surface gravity based on its mass and radius. On the Moon (g = 1.62), you'd jump 6× higher than on Earth! On Jupiter (g = 24.79), you'd barely leave the ground.",
                icon: "sparkles",
                accentColor: Theme.solarOrange,
                isVisible: $showInfo
            )
        }
        .navigationTitle("Planet Explorer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                InfoButton(accentColor: Theme.solarOrange) {
                    withAnimation { showInfo.toggle() }
                }
            }
        }
        .onChange(of: selectedPlanet) { _, planet in
            sceneController.setPlanet(planet)
        }
    }

    private func planetButton(_ planet: PlanetData) -> some View {
        let isSelected = selectedPlanet == planet
        return Button {
            withAnimation(.spring(response: 0.4)) {
                selectedPlanet = planet
            }
            HapticManager.shared.selection()
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(planet.color.opacity(isSelected ? 0.3 : 0.1))
                        .frame(width: 50, height: 50)

                    Image(systemName: planet.icon)
                        .font(.system(size: 22))
                        .foregroundColor(planet.color)
                }

                Text(planet.name)
                    .font(Theme.caption(11))
                    .foregroundColor(isSelected ? .white : Theme.dimText)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 6)
            .background(isSelected ? Color.white.opacity(0.06) : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .accessibilityLabel("\(planet.name), gravity \(planet.g) meters per second squared")
    }

    private func statBox(label: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(Theme.caption(11))
                .foregroundColor(Theme.dimText)
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            Text(unit)
                .font(Theme.caption(10))
                .foregroundColor(Theme.dimText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .glassCard(cornerRadius: 12)
    }
}

// MARK: - Planet Jump Scene Controller
@MainActor
class PlanetJumpSceneController: ObservableObject {
    let scene: SCNScene
    let cameraNode: SCNNode
    private var characterNode: SCNNode?
    private var groundNode: SCNNode?

    init() {
        scene = SCNScene()
        scene.background.contents = UIColor(red: 0.04, green: 0.04, blue: 0.12, alpha: 1.0)

        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zFar = 100
        cameraNode.position = SCNVector3(0, 3, 8)
        cameraNode.look(at: SCNVector3(0, 1.5, 0))
        scene.rootNode.addChildNode(cameraNode)

        setupLighting()
        createGround(color: UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1))
        createCharacter()
        addStars()
    }

    private func setupLighting() {
        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 400
        scene.rootNode.addChildNode(ambient)

        let directional = SCNNode()
        directional.light = SCNLight()
        directional.light?.type = .directional
        directional.light?.intensity = 800
        directional.light?.castsShadow = true
        directional.position = SCNVector3(5, 10, 5)
        directional.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(directional)
    }

    private func createGround(color: UIColor) {
        groundNode?.removeFromParentNode()

        let groundGeo = SCNBox(width: 20, height: 0.3, length: 20, chamferRadius: 0.1)
        let mat = SCNMaterial()
        mat.diffuse.contents = color.withAlphaComponent(0.7)
        mat.metalness.contents = 0.2
        groundGeo.materials = [mat]
        let ground = SCNNode(geometry: groundGeo)
        ground.position = SCNVector3(0, -0.15, 0)
        scene.rootNode.addChildNode(ground)
        groundNode = ground

        // Grid lines on ground
        for i in -5...5 {
            let lineGeo = SCNBox(width: 20, height: 0.02, length: 0.02, chamferRadius: 0)
            let lineMat = SCNMaterial()
            lineMat.diffuse.contents = UIColor.white.withAlphaComponent(0.1)
            lineGeo.materials = [lineMat]
            let line = SCNNode(geometry: lineGeo)
            line.position = SCNVector3(0, 0.01, Float(i) * 2)
            ground.addChildNode(line)
        }
    }

    private func createCharacter() {
        let character = SCNNode()

        // Body
        let bodyGeo = SCNCapsule(capRadius: 0.3, height: 1.0)
        let bodyMat = SCNMaterial()
        bodyMat.diffuse.contents = UIColor.white
        bodyMat.metalness.contents = 0.1
        bodyGeo.materials = [bodyMat]
        let body = SCNNode(geometry: bodyGeo)
        character.addChildNode(body)

        // Head
        let headGeo = SCNSphere(radius: 0.22)
        let headMat = SCNMaterial()
        headMat.diffuse.contents = UIColor(red: 0.9, green: 0.8, blue: 0.7, alpha: 1)
        headGeo.materials = [headMat]
        let head = SCNNode(geometry: headGeo)
        head.position = SCNVector3(0, 0.72, 0)
        character.addChildNode(head)

        // Legs
        for x: Float in [-0.12, 0.12] {
            let legGeo = SCNCapsule(capRadius: 0.08, height: 0.7)
            let legMat = SCNMaterial()
            legMat.diffuse.contents = UIColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 1)
            legGeo.materials = [legMat]
            let leg = SCNNode(geometry: legGeo)
            leg.position = SCNVector3(x, -0.85, 0)
            character.addChildNode(leg)
        }

        character.position = SCNVector3(0, 1.7, 0)
        scene.rootNode.addChildNode(character)
        characterNode = character
    }

    private func addStars() {
        for _ in 0..<60 {
            let starGeo = SCNSphere(radius: CGFloat.random(in: 0.02...0.06))
            let mat = SCNMaterial()
            mat.diffuse.contents = UIColor.white
            mat.emission.contents = UIColor.white
            starGeo.materials = [mat]
            let star = SCNNode(geometry: starGeo)
            star.position = SCNVector3(
                Float.random(in: -30...30),
                Float.random(in: 5...30),
                Float.random(in: -30...(-5))
            )
            scene.rootNode.addChildNode(star)
        }
    }

    func setPlanet(_ planet: PlanetData) {
        createGround(color: UIColor(planet.color))

        // Reset character
        characterNode?.removeAllActions()
        characterNode?.position = SCNVector3(0, 1.7, 0)
    }

    func jump(height: Float) {
        guard let character = characterNode else { return }

        character.removeAllActions()
        character.position = SCNVector3(0, 1.7, 0)

        let clampedHeight = min(height, 12.0) // Clamp for visual
        let jumpDuration = TimeInterval(sqrt(2.0 * clampedHeight / 9.81)) * 2

        let jumpUp = SCNAction.moveBy(x: 0, y: CGFloat(clampedHeight), z: 0, duration: jumpDuration / 2)
        jumpUp.timingMode = .easeOut
        let jumpDown = SCNAction.moveBy(x: 0, y: CGFloat(-clampedHeight), z: 0, duration: jumpDuration / 2)
        jumpDown.timingMode = .easeIn

        // Squash on landing
        let squash = SCNAction.customAction(duration: 0.1) { node, elapsed in
            let t = elapsed / 0.1
            node.scale = SCNVector3(1.0 + Float(t) * 0.1, 1.0 - Float(t) * 0.15, 1.0 + Float(t) * 0.1)
        }
        let unsquash = SCNAction.customAction(duration: 0.15) { node, elapsed in
            let t = elapsed / 0.15
            node.scale = SCNVector3(1.1 - Float(t) * 0.1, 0.85 + Float(t) * 0.15, 1.1 - Float(t) * 0.1)
        }

        let sequence = SCNAction.sequence([jumpUp, jumpDown, squash, unsquash])
        character.runAction(sequence) {
            DispatchQueue.main.async {
                HapticManager.shared.collision()
            }
        }
    }
}
