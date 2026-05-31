import SwiftUI
import SceneKit

// MARK: - Module 5: Gravity & Human Body
struct HumanBodyView: View {
    @State private var selectedScenario = 0
    @State private var showInfo = false
    @State private var sceneController = BodyForceSceneController()

    let scenarios = [
        BodyScenario(name: "Standing", icon: "figure.stand", description: "Normal force balances weight", weight: 700, normalForce: 700, apparentWeight: 700),
        BodyScenario(name: "Sitting", icon: "figure.seated.seatbelt", description: "Chair provides normal force", weight: 700, normalForce: 700, apparentWeight: 700),
        BodyScenario(name: "Elevator ↑", icon: "arrow.up.square.fill", description: "Accelerating up: you feel heavier", weight: 700, normalForce: 910, apparentWeight: 910),
        BodyScenario(name: "Free Fall", icon: "arrow.down", description: "No normal force: weightlessness!", weight: 700, normalForce: 0, apparentWeight: 0),
        BodyScenario(name: "Space", icon: "sparkles", description: "Continuous free fall around Earth", weight: 0, normalForce: 0, apparentWeight: 0),
    ]

    var currentScenario: BodyScenario {
        scenarios[selectedScenario]
    }

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                // Scenario picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(0..<scenarios.count, id: \.self) { i in
                            scenarioButton(index: i)
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
                .onChange(of: selectedScenario) { _, newValue in
                    sceneController.updateScenario(scenarios[newValue])
                    HapticManager.shared.impact(.medium)
                }

                // Force info
                VStack(spacing: 10) {
                    Text(currentScenario.description)
                        .font(Theme.subtitle(15))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    HStack(spacing: 16) {
                        forceIndicator(label: "Weight", value: currentScenario.weight, unit: "N", color: Theme.plasmaRed, icon: "arrow.down")
                        forceIndicator(label: "Normal", value: currentScenario.normalForce, unit: "N", color: Theme.auroraGreen, icon: "arrow.up")
                        forceIndicator(label: "Apparent", value: currentScenario.apparentWeight, unit: "N", color: Theme.solarOrange, icon: "scalemass.fill")
                    }
                }
                .padding(16)
                .glassCard(cornerRadius: 16)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }

            EducationalOverlay(
                title: "Forces on Your Body",
                description: "Your 'weight' is the gravitational pull on you. The normal force is what the ground/chair pushes back. When these don't match, you feel heavier or lighter!",
                icon: "figure.stand",
                accentColor: Theme.plasmaRed,
                isVisible: $showInfo
            )
        }
        .navigationTitle("Gravity & Body")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                InfoButton(accentColor: Theme.plasmaRed) {
                    withAnimation { showInfo.toggle() }
                }
            }
        }
        .onAppear {
            sceneController.updateScenario(scenarios[0])
        }
    }

    private func scenarioButton(index: Int) -> some View {
        let scenario = scenarios[index]
        let isSelected = selectedScenario == index

        return Button {
            withAnimation(.spring(response: 0.4)) {
                selectedScenario = index
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: scenario.icon)
                    .font(.system(size: 18))
                Text(scenario.name)
                    .font(Theme.caption(11))
            }
            .foregroundColor(isSelected ? .white : Theme.secondaryText)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? Theme.plasmaRed.opacity(0.3) : Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Theme.plasmaRed.opacity(0.5) : .clear, lineWidth: 1)
            )
        }
        .accessibilityLabel("\(scenario.name) scenario")
    }

    private func forceIndicator(label: String, value: Double, unit: String, color: Color, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            Text(label)
                .font(Theme.caption(10))
                .foregroundColor(Theme.dimText)
            Text("\(Int(value))")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            Text(unit)
                .font(Theme.caption(9))
                .foregroundColor(Theme.dimText)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Body Scenario Data
struct BodyScenario {
    let name: String
    let icon: String
    let description: String
    let weight: Double      // Newtons
    let normalForce: Double // Newtons
    let apparentWeight: Double
}

// MARK: - Body Force Scene Controller
@MainActor
class BodyForceSceneController: ObservableObject {
    let scene: SCNScene
    let cameraNode: SCNNode
    private var characterNode: SCNNode?
    private var weightArrow: SCNNode?
    private var normalArrow: SCNNode?
    private var groundNode: SCNNode?
    private var platformNode: SCNNode?

    init() {
        scene = SCNScene()
        scene.background.contents = UIColor(red: 0.04, green: 0.04, blue: 0.12, alpha: 1.0)

        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zFar = 50
        cameraNode.position = SCNVector3(0, 2, 7)
        cameraNode.look(at: SCNVector3(0, 1.5, 0))
        scene.rootNode.addChildNode(cameraNode)

        setupLighting()
        createCharacter()
        createGround()
    }

    private func setupLighting() {
        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 350
        ambient.light?.color = UIColor(white: 0.7, alpha: 1)
        scene.rootNode.addChildNode(ambient)

        let directional = SCNNode()
        directional.light = SCNLight()
        directional.light?.type = .directional
        directional.light?.intensity = 700
        directional.light?.castsShadow = true
        directional.position = SCNVector3(3, 8, 5)
        directional.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(directional)
    }

    private func createCharacter() {
        let character = SCNNode()

        // Torso
        let torsoGeo = SCNCapsule(capRadius: 0.3, height: 1.0)
        let torsoMat = SCNMaterial()
        torsoMat.diffuse.contents = UIColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 1.0)
        torsoGeo.materials = [torsoMat]
        let torso = SCNNode(geometry: torsoGeo)
        character.addChildNode(torso)

        // Head
        let headGeo = SCNSphere(radius: 0.22)
        let headMat = SCNMaterial()
        headMat.diffuse.contents = UIColor(red: 0.9, green: 0.8, blue: 0.7, alpha: 1.0)
        headGeo.materials = [headMat]
        let head = SCNNode(geometry: headGeo)
        head.position = SCNVector3(0, 0.72, 0)
        character.addChildNode(head)

        // Legs
        for x: Float in [-0.15, 0.15] {
            let legGeo = SCNCapsule(capRadius: 0.1, height: 0.8)
            let legMat = SCNMaterial()
            legMat.diffuse.contents = UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)
            legGeo.materials = [legMat]
            let leg = SCNNode(geometry: legGeo)
            leg.position = SCNVector3(x, -0.9, 0)
            character.addChildNode(leg)
        }

        // Arms
        for x: Float in [-0.45, 0.45] {
            let armGeo = SCNCapsule(capRadius: 0.08, height: 0.7)
            let armMat = SCNMaterial()
            armMat.diffuse.contents = UIColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 1.0)
            armGeo.materials = [armMat]
            let arm = SCNNode(geometry: armGeo)
            arm.position = SCNVector3(x, -0.1, 0)
            character.addChildNode(arm)
        }

        character.position = SCNVector3(0, 1.8, 0)
        scene.rootNode.addChildNode(character)
        characterNode = character
    }

    private func createGround() {
        let groundGeo = SCNBox(width: 6, height: 0.15, length: 4, chamferRadius: 0.05)
        let groundMat = SCNMaterial()
        groundMat.diffuse.contents = UIColor(red: 0.15, green: 0.15, blue: 0.22, alpha: 1.0)
        groundMat.metalness.contents = 0.3
        groundGeo.materials = [groundMat]
        let ground = SCNNode(geometry: groundGeo)
        ground.position = SCNVector3(0, 0, 0)
        scene.rootNode.addChildNode(ground)
        groundNode = ground
    }

    func updateScenario(_ scenario: BodyScenario) {
        // Remove old arrows and platform
        weightArrow?.removeFromParentNode()
        normalArrow?.removeFromParentNode()
        platformNode?.removeFromParentNode()

        guard let character = characterNode else { return }

        // Reset character position
        character.removeAllActions()
        character.position = SCNVector3(0, 1.8, 0)
        character.eulerAngles = SCNVector3(0, 0, 0)

        switch scenario.name {
        case "Sitting":
            // Add chair/platform
            let chairGeo = SCNBox(width: 1.0, height: 0.6, length: 0.8, chamferRadius: 0.05)
            let chairMat = SCNMaterial()
            chairMat.diffuse.contents = UIColor(red: 0.4, green: 0.25, blue: 0.15, alpha: 1.0)
            chairGeo.materials = [chairMat]
            let chair = SCNNode(geometry: chairGeo)
            chair.position = SCNVector3(0, 0.38, 0)
            scene.rootNode.addChildNode(chair)
            platformNode = chair
            character.position = SCNVector3(0, 1.6, 0)

        case "Elevator ↑":
            // Elevator platform
            let elevGeo = SCNBox(width: 2, height: 0.15, length: 2, chamferRadius: 0.05)
            let elevMat = SCNMaterial()
            elevMat.diffuse.contents = UIColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 1.0)
            elevMat.metalness.contents = 0.5
            elevGeo.materials = [elevMat]
            let elev = SCNNode(geometry: elevGeo)
            elev.position = SCNVector3(0, 0.15, 0)
            scene.rootNode.addChildNode(elev)
            platformNode = elev

            let moveUp = SCNAction.moveBy(x: 0, y: 1.5, z: 0, duration: 2.0)
            moveUp.timingMode = .easeInEaseOut
            let moveDown = SCNAction.moveBy(x: 0, y: -1.5, z: 0, duration: 2.0)
            moveDown.timingMode = .easeInEaseOut
            let sequence = SCNAction.sequence([moveUp, moveDown])
            elev.runAction(SCNAction.repeatForever(sequence))
            character.runAction(SCNAction.repeatForever(sequence))

        case "Free Fall":
            let fall = SCNAction.moveBy(x: 0, y: -2, z: 0, duration: 1.5)
            fall.timingMode = .easeIn
            let reset = SCNAction.move(to: SCNVector3(0, 3, 0), duration: 0)
            character.position = SCNVector3(0, 3, 0)
            character.runAction(SCNAction.repeatForever(SCNAction.sequence([fall, reset])))

        case "Space":
            character.position = SCNVector3(0, 2.5, 0)
            let float = SCNAction.moveBy(x: 0, y: 0.3, z: 0, duration: 2.0)
            float.timingMode = .easeInEaseOut
            let floatBack = float.reversed()
            let rotate = SCNAction.rotateBy(x: 0, y: 0, z: 0.1, duration: 4.0)
            character.runAction(SCNAction.repeatForever(SCNAction.sequence([float, floatBack])))
            character.runAction(SCNAction.repeatForever(rotate))

        default:
            break
        }

        // Weight arrow (down, red)
        if scenario.weight > 0 {
            let arrowLength = Float(scenario.weight / 700.0) * 1.5
            let arrow = createArrow(length: arrowLength, color: UIColor(red: 1, green: 0.3, blue: 0.4, alpha: 0.9), direction: .down)
            arrow.position = SCNVector3(0.3, -1.3, 0)
            character.addChildNode(arrow)
            weightArrow = arrow
        }

        // Normal force arrow (up, green)
        if scenario.normalForce > 0 {
            let arrowLength = Float(scenario.normalForce / 700.0) * 1.5
            let arrow = createArrow(length: arrowLength, color: UIColor(red: 0.2, green: 0.9, blue: 0.6, alpha: 0.9), direction: .up)
            arrow.position = SCNVector3(-0.3, -1.3, 0)
            character.addChildNode(arrow)
            normalArrow = arrow
        }
    }

    enum ArrowDirection { case up, down }

    private func createArrow(length: Float, color: UIColor, direction: ArrowDirection) -> SCNNode {
        let parent = SCNNode()
        let sign: Float = direction == .down ? -1 : 1

        let cylGeo = SCNCylinder(radius: 0.04, height: CGFloat(length))
        let mat = SCNMaterial()
        mat.diffuse.contents = color
        mat.emission.contents = color
        cylGeo.materials = [mat]
        let cyl = SCNNode(geometry: cylGeo)
        cyl.position = SCNVector3(0, sign * length / 2, 0)
        parent.addChildNode(cyl)

        let coneGeo = SCNCone(topRadius: 0, bottomRadius: 0.1, height: 0.2)
        coneGeo.materials = [mat]
        let cone = SCNNode(geometry: coneGeo)
        cone.position = SCNVector3(0, sign * (length + 0.1), 0)
        if direction == .down {
            cone.eulerAngles.z = .pi
        }
        parent.addChildNode(cone)

        // Label
        let textGeo = SCNText(string: direction == .down ? "W" : "N", extrusionDepth: 0.01)
        textGeo.font = UIFont.systemFont(ofSize: 0.3, weight: .bold)
        textGeo.materials = [mat]
        let textNode = SCNNode(geometry: textGeo)
        textNode.position = SCNVector3(0.15, sign * length / 2, 0)
        textNode.scale = SCNVector3(1, 1, 1)
        parent.addChildNode(textNode)

        return parent
    }
}
