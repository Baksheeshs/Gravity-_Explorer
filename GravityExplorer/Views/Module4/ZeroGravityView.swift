import SwiftUI
import SceneKit

// MARK: - Module 4: Zero Gravity Experience
struct ZeroGravityView: View {
    @StateObject private var motionManager = MotionManager()
    @State private var gravityEnabled = true
    @State private var showInfo = false
    @State private var sceneController = SpacecraftSceneController()

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                // SceneKit View
                SceneView(
                    scene: sceneController.scene,
                    pointOfView: sceneController.cameraNode,
                    options: [.allowsCameraControl, .autoenablesDefaultLighting]
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 12)
                .padding(.top, 8)

                // Controls
                VStack(spacing: 12) {
                    // Gravity Toggle
                    HStack {
                        Toggle(isOn: $gravityEnabled) {
                            HStack(spacing: 8) {
                                Image(systemName: gravityEnabled ? "arrow.down.circle.fill" : "circle.dashed")
                                    .foregroundColor(gravityEnabled ? Theme.plasmaRed : Theme.cosmicCyan)
                                    .font(.system(size: 20))
                                VStack(alignment: .leading) {
                                    Text(gravityEnabled ? "Gravity ON" : "Zero Gravity")
                                        .font(Theme.subtitle(15))
                                        .foregroundColor(.white)
                                    Text(gravityEnabled ? "Objects fall normally" : "Objects float freely")
                                        .font(Theme.caption(11))
                                        .foregroundColor(Theme.dimText)
                                }
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Theme.cosmicCyan))
                        .onChange(of: gravityEnabled) { _, enabled in
                            sceneController.setGravity(enabled: enabled)
                            if !enabled {
                                HapticManager.shared.weightless()
                            } else {
                                HapticManager.shared.forceApplied()
                            }
                        }
                    }

                    // Motion controls info
                    if !gravityEnabled {
                        HStack(spacing: 8) {
                            Image(systemName: "iphone.gen3.radiowaves.left.and.right")
                                .foregroundColor(Theme.cosmicCyan)
                            Text("Tilt your device to push floating objects")
                                .font(Theme.caption(12))
                                .foregroundColor(Theme.secondaryText)
                        }
                        .padding(10)
                        .background(Theme.cosmicCyan.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    // Spawn buttons
                    HStack(spacing: 10) {
                        spawnButton(label: "Add Cup", icon: "cup.and.saucer.fill", color: Theme.solarOrange) {
                            sceneController.spawnFloatingObject(type: .cup)
                        }
                        spawnButton(label: "Add Tool", icon: "wrench.fill", color: Theme.auroraGreen) {
                            sceneController.spawnFloatingObject(type: .tool)
                        }
                        spawnButton(label: "Reset", icon: "arrow.counterclockwise", color: Theme.dimText) {
                            sceneController.resetScene()
                        }
                    }
                }
                .padding(16)
                .glassCard(cornerRadius: 16)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }

            EducationalOverlay(
                title: "Weightlessness",
                description: "In space, astronauts aren't truly gravity-free — they're in continuous free fall around Earth! This creates the sensation of weightlessness. Everything floats because everything falls together.",
                icon: "airplane.departure",
                accentColor: Theme.cosmicCyan,
                isVisible: $showInfo
            )
        }
        .navigationTitle("Zero Gravity")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                InfoButton(accentColor: Theme.cosmicCyan) {
                    withAnimation { showInfo.toggle() }
                }
            }
        }
        .onAppear {
            motionManager.startUpdates()
        }
        .onDisappear {
            motionManager.stopUpdates()
        }
        .onReceive(Timer.publish(every: 1.0/30.0, on: .main, in: .common).autoconnect()) { _ in
            if !gravityEnabled {
                sceneController.applyMotionForce(
                    roll: motionManager.roll,
                    pitch: motionManager.pitch
                )
            }
        }
    }

    private func spawnButton(label: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(label)
                    .font(Theme.caption(11))
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

// MARK: - Spacecraft Scene Controller
@MainActor
class SpacecraftSceneController: ObservableObject {
    let scene: SCNScene
    let cameraNode: SCNNode
    private var floatingObjects: [SCNNode] = []
    private var astronautNode: SCNNode?

    enum FloatingObjectType { case cup, tool }

    init() {
        scene = SCNScene()
        scene.background.contents = UIColor(red: 0.02, green: 0.02, blue: 0.08, alpha: 1.0)
        scene.physicsWorld.gravity = SCNVector3(0, -9.81, 0)

        // Camera
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zFar = 100
        cameraNode.position = SCNVector3(0, 2, 8)
        cameraNode.look(at: SCNVector3(0, 1, 0))
        scene.rootNode.addChildNode(cameraNode)

        setupLighting()
        createSpacecraft()
        createAstronaut()
    }

    private func setupLighting() {
        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 400
        ambient.light?.color = UIColor(red: 0.6, green: 0.7, blue: 1.0, alpha: 1.0)
        scene.rootNode.addChildNode(ambient)

        let spot = SCNNode()
        spot.light = SCNLight()
        spot.light?.type = .spot
        spot.light?.intensity = 1000
        spot.light?.spotInnerAngle = 30
        spot.light?.spotOuterAngle = 80
        spot.light?.castsShadow = true
        spot.position = SCNVector3(0, 5, 3)
        spot.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(spot)
    }

    private func createSpacecraft() {
        // Floor
        let floor = SCNBox(width: 8, height: 0.2, length: 6, chamferRadius: 0.05)
        let floorMat = SCNMaterial()
        floorMat.diffuse.contents = UIColor(red: 0.15, green: 0.15, blue: 0.20, alpha: 1.0)
        floorMat.metalness.contents = 0.6
        floor.materials = [floorMat]
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(0, -0.1, 0)
        floorNode.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(floorNode)

        // Walls
        let wallMat = SCNMaterial()
        wallMat.diffuse.contents = UIColor(red: 0.12, green: 0.12, blue: 0.18, alpha: 0.7)
        wallMat.metalness.contents = 0.4

        // Back wall
        let backWall = SCNBox(width: 8, height: 5, length: 0.1, chamferRadius: 0)
        backWall.materials = [wallMat]
        let backWallNode = SCNNode(geometry: backWall)
        backWallNode.position = SCNVector3(0, 2.5, -3)
        backWallNode.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(backWallNode)

        // Ceiling
        let ceiling = SCNBox(width: 8, height: 0.1, length: 6, chamferRadius: 0)
        ceiling.materials = [wallMat]
        let ceilingNode = SCNNode(geometry: ceiling)
        ceilingNode.position = SCNVector3(0, 5, 0)
        ceilingNode.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(ceilingNode)

        // Side walls
        for x: Float in [-4, 4] {
            let sideWall = SCNBox(width: 0.1, height: 5, length: 6, chamferRadius: 0)
            sideWall.materials = [wallMat]
            let sideNode = SCNNode(geometry: sideWall)
            sideNode.position = SCNVector3(x, 2.5, 0)
            sideNode.physicsBody = SCNPhysicsBody.static()
            scene.rootNode.addChildNode(sideNode)
        }

        // Window (glowing circle on back wall)
        let windowGeo = SCNCylinder(radius: 0.8, height: 0.05)
        let windowMat = SCNMaterial()
        windowMat.diffuse.contents = UIColor(red: 0.1, green: 0.2, blue: 0.5, alpha: 1.0)
        windowMat.emission.contents = UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
        windowGeo.materials = [windowMat]
        let window = SCNNode(geometry: windowGeo)
        window.position = SCNVector3(0, 3, -2.9)
        window.eulerAngles.x = .pi / 2
        scene.rootNode.addChildNode(window)
    }

    private func createAstronaut() {
        let astronaut = SCNNode()

        // Body (capsule)
        let bodyGeo = SCNCapsule(capRadius: 0.35, height: 1.2)
        let bodyMat = SCNMaterial()
        bodyMat.diffuse.contents = UIColor.white
        bodyMat.metalness.contents = 0.2
        bodyGeo.materials = [bodyMat]
        let body = SCNNode(geometry: bodyGeo)
        astronaut.addChildNode(body)

        // Head (sphere)
        let headGeo = SCNSphere(radius: 0.25)
        let headMat = SCNMaterial()
        headMat.diffuse.contents = UIColor(red: 0.9, green: 0.85, blue: 0.75, alpha: 1.0)
        headGeo.materials = [headMat]
        let head = SCNNode(geometry: headGeo)
        head.position = SCNVector3(0, 0.85, 0)
        astronaut.addChildNode(head)

        // Helmet visor
        let visorGeo = SCNSphere(radius: 0.28)
        let visorMat = SCNMaterial()
        visorMat.diffuse.contents = UIColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 0.6)
        visorMat.metalness.contents = 0.8
        visorMat.transparency = 0.6
        visorGeo.materials = [visorMat]
        let visor = SCNNode(geometry: visorGeo)
        visor.position = SCNVector3(0, 0.85, 0.05)
        astronaut.addChildNode(visor)

        astronaut.position = SCNVector3(0, 1.5, 0)
        astronaut.physicsBody = SCNPhysicsBody.dynamic()
        astronaut.physicsBody?.mass = 70
        astronaut.physicsBody?.restitution = 0.2
        astronaut.physicsBody?.damping = 0.3

        scene.rootNode.addChildNode(astronaut)
        astronautNode = astronaut
    }

    func setGravity(enabled: Bool) {
        if enabled {
            scene.physicsWorld.gravity = SCNVector3(0, -9.81, 0)
        } else {
            scene.physicsWorld.gravity = SCNVector3(0, 0, 0)
            // Give floating objects a gentle drift
            for obj in floatingObjects {
                let dx = Float.random(in: -0.3...0.3)
                let dy = Float.random(in: 0.1...0.5)
                let dz = Float.random(in: -0.2...0.2)
                obj.physicsBody?.applyForce(SCNVector3(dx, dy, dz), asImpulse: true)
            }
            astronautNode?.physicsBody?.applyForce(SCNVector3(0, 0.5, 0), asImpulse: true)
            astronautNode?.physicsBody?.applyTorque(SCNVector4(1, 0, 0, 0.1), asImpulse: true)
        }
    }

    func spawnFloatingObject(type: FloatingObjectType) {
        let node: SCNNode
        switch type {
        case .cup:
            let geo = SCNCylinder(radius: 0.15, height: 0.3)
            let mat = SCNMaterial()
            mat.diffuse.contents = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
            mat.metalness.contents = 0.3
            geo.materials = [mat]
            node = SCNNode(geometry: geo)
        case .tool:
            let geo = SCNBox(width: 0.1, height: 0.5, length: 0.1, chamferRadius: 0.02)
            let mat = SCNMaterial()
            mat.diffuse.contents = UIColor(red: 0.6, green: 0.6, blue: 0.65, alpha: 1.0)
            mat.metalness.contents = 0.7
            geo.materials = [mat]
            node = SCNNode(geometry: geo)
        }

        let x = Float.random(in: -2...2)
        let y = Float.random(in: 2...4)
        let z = Float.random(in: -1...1)
        node.position = SCNVector3(x, y, z)
        node.physicsBody = SCNPhysicsBody.dynamic()
        node.physicsBody?.mass = 0.5
        node.physicsBody?.restitution = 0.3
        node.physicsBody?.damping = 0.1

        scene.rootNode.addChildNode(node)
        floatingObjects.append(node)

        if floatingObjects.count > 10 {
            let old = floatingObjects.removeFirst()
            old.removeFromParentNode()
        }
    }

    func applyMotionForce(roll: Double, pitch: Double) {
        let forceX = Float(roll) * 2.0
        let forceZ = Float(-pitch) * 2.0
        let force = SCNVector3(forceX, 0, forceZ)

        for obj in floatingObjects {
            obj.physicsBody?.applyForce(force, asImpulse: false)
        }
        astronautNode?.physicsBody?.applyForce(force, asImpulse: false)
    }

    func resetScene() {
        for obj in floatingObjects {
            obj.removeFromParentNode()
        }
        floatingObjects.removeAll()

        astronautNode?.position = SCNVector3(0, 1.5, 0)
        astronautNode?.physicsBody?.velocity = SCNVector3(0, 0, 0)
        astronautNode?.physicsBody?.angularVelocity = SCNVector4(0, 0, 0, 0)
        astronautNode?.eulerAngles = SCNVector3(0, 0, 0)
    }
}
