import SwiftUI
import SceneKit

// MARK: - Module 1: What is Gravity?
struct WhatIsGravityView: View {
    @State private var gravityStrength: Double = 9.81
    @State private var showInfo = false
    @State private var sceneController = GravitySceneController()

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
                .overlay(alignment: .topLeading) {
                    // Drop object buttons
                    VStack(spacing: 8) {
                        dropButton(label: "Ball", icon: "circle.fill", color: Theme.plasmaRed) {
                            sceneController.dropObject(type: .sphere)
                            HapticManager.shared.forceApplied(intensity: 0.5)
                        }
                        dropButton(label: "Cube", icon: "square.fill", color: Theme.solarOrange) {
                            sceneController.dropObject(type: .box)
                            HapticManager.shared.forceApplied(intensity: 0.5)
                        }
                        dropButton(label: "Cylinder", icon: "capsule.fill", color: Theme.auroraGreen) {
                            sceneController.dropObject(type: .cylinder)
                            HapticManager.shared.forceApplied(intensity: 0.5)
                        }
                        Button {
                            sceneController.resetObjects()
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 36)
                                .background(Color.white.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(.leading, 24)
                    .padding(.top, 16)
                }

                // Controls
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "scalemass.fill")
                            .foregroundColor(Theme.starGlow)
                        Text("Gravity: \(String(format: "%.1f", gravityStrength)) m/s²")
                            .font(Theme.subtitle(15))
                            .foregroundColor(.white)
                        Spacer()
                    }

                    Slider(value: $gravityStrength, in: 0...30, step: 0.1)
                        .tint(Theme.starGlow)
                        .onChange(of: gravityStrength) { _, newValue in
                            sceneController.setGravity(newValue)
                        }

                    HStack {
                        Text("No Gravity")
                            .font(Theme.caption(11))
                            .foregroundColor(Theme.dimText)
                        Spacer()
                        Text("Super Heavy")
                            .font(Theme.caption(11))
                            .foregroundColor(Theme.dimText)
                    }
                }
                .padding(16)
                .glassCard(cornerRadius: 16)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }

            // Educational Overlay
            EducationalOverlay(
                title: "What is Gravity?",
                description: "Gravity is the force that pulls objects toward each other. Every object with mass exerts gravity. Drop different objects — they all fall at the same rate regardless of mass!",
                icon: "globe.americas.fill",
                accentColor: Theme.starGlow,
                isVisible: $showInfo
            )
        }
        .navigationTitle("What is Gravity?")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                InfoButton(accentColor: Theme.starGlow) {
                    withAnimation { showInfo.toggle() }
                }
            }
        }
    }

    private func dropButton(label: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(label)
                    .font(Theme.caption(12))
            }
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(color.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .accessibilityLabel("Drop \(label)")
    }
}

// MARK: - Scene Controller
@MainActor
class GravitySceneController: ObservableObject {
    let scene: SCNScene
    let cameraNode: SCNNode
    private var droppedObjects: [SCNNode] = []

    enum ObjectType { case sphere, box, cylinder }

    init() {
        scene = SCNScene()
        scene.background.contents = UIColor(red: 0.04, green: 0.04, blue: 0.12, alpha: 1.0)

        // Camera
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zFar = 200
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 15)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(cameraNode)

        // Physics
        scene.physicsWorld.gravity = SCNVector3(0, -9.81, 0)

        // Lighting
        setupLighting()

        // Earth
        createEarth()

        // Ground
        createGround()
    }

    private func setupLighting() {
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 300
        ambientLight.light?.color = UIColor(white: 0.6, alpha: 1)
        scene.rootNode.addChildNode(ambientLight)

        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.intensity = 800
        directionalLight.light?.color = UIColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 1)
        directionalLight.light?.castsShadow = true
        directionalLight.position = SCNVector3(5, 10, 5)
        directionalLight.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(directionalLight)
    }

    private func createEarth() {
        let earthGeometry = SCNSphere(radius: 2.0)
        earthGeometry.segmentCount = 64

        // Generate a procedural Earth texture
        let material = SCNMaterial()
        material.diffuse.contents = generateEarthTexture()
        material.specular.contents = UIColor(white: 0.4, alpha: 1)
        material.shininess = 0.25
        material.emission.contents = generateEarthEmission()
        material.locksAmbientWithDiffuse = true

        earthGeometry.materials = [material]
        let earthNode = SCNNode(geometry: earthGeometry)
        earthNode.position = SCNVector3(0, -3, 0)

        // Slow rotation
        let rotate = SCNAction.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 30)
        earthNode.runAction(SCNAction.repeatForever(rotate))

        // Static physics body (ground)
        earthNode.physicsBody = SCNPhysicsBody.static()
        earthNode.physicsBody?.restitution = 0.3
        earthNode.name = "earth"
        scene.rootNode.addChildNode(earthNode)

        // Cloud layer — slightly larger, semi-transparent white sphere
        let cloudGeometry = SCNSphere(radius: 2.04)
        cloudGeometry.segmentCount = 48
        let cloudMaterial = SCNMaterial()
        cloudMaterial.diffuse.contents = generateCloudTexture()
        cloudMaterial.transparent.contents = generateCloudTexture()
        cloudMaterial.isDoubleSided = true
        cloudMaterial.transparencyMode = .aOne
        cloudGeometry.materials = [cloudMaterial]
        let cloudNode = SCNNode(geometry: cloudGeometry)
        cloudNode.position = earthNode.position
        let cloudRotate = SCNAction.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 45)
        cloudNode.runAction(SCNAction.repeatForever(cloudRotate))
        scene.rootNode.addChildNode(cloudNode)

        // Atmosphere glow ring
        let atmosGeometry = SCNTorus(ringRadius: 2.15, pipeRadius: 0.06)
        let atmosMaterial = SCNMaterial()
        atmosMaterial.diffuse.contents = UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.25)
        atmosMaterial.emission.contents = UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.4)
        atmosGeometry.materials = [atmosMaterial]
        let atmosNode = SCNNode(geometry: atmosGeometry)
        atmosNode.position = earthNode.position
        atmosNode.eulerAngles.x = .pi / 2
        scene.rootNode.addChildNode(atmosNode)
    }

    /// Generates a procedural Earth texture with oceans, continents, and ice caps.
    private func generateEarthTexture() -> UIImage {
        let w = 1024
        let h = 512
        let size = CGSize(width: w, height: h)

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let gc = ctx.cgContext

            // Deep ocean base
            UIColor(red: 0.04, green: 0.15, blue: 0.55, alpha: 1).setFill()
            gc.fill(CGRect(origin: .zero, size: size))

            // Shallow ocean variation
            UIColor(red: 0.06, green: 0.22, blue: 0.65, alpha: 0.5).setFill()
            for _ in 0..<30 {
                let cx = CGFloat.random(in: 0...CGFloat(w))
                let cy = CGFloat.random(in: 60...CGFloat(h - 60))
                let rw = CGFloat.random(in: 40...120)
                let rh = CGFloat.random(in: 20...60)
                gc.fillEllipse(in: CGRect(x: cx - rw/2, y: cy - rh/2, width: rw, height: rh))
            }

            // ---------- Continents ----------
            // Each continent drawn as overlapping ellipses with green/brown tones

            // North America
            drawContinent(gc, shapes: [
                (x: 200, y: 120, w: 130, h: 80),  // main body
                (x: 180, y: 100, w: 80, h: 50),    // Canada
                (x: 230, y: 160, w: 40, h: 50),    // Florida/Mexico
                (x: 160, y: 130, w: 50, h: 40),    // West coast
            ], baseGreen: true)

            // South America
            drawContinent(gc, shapes: [
                (x: 290, y: 250, w: 60, h: 110),
                (x: 280, y: 230, w: 50, h: 50),
                (x: 300, y: 300, w: 40, h: 60),
            ], baseGreen: true)

            // Europe
            drawContinent(gc, shapes: [
                (x: 490, y: 110, w: 70, h: 40),
                (x: 480, y: 130, w: 40, h: 30),
                (x: 510, y: 100, w: 50, h: 25),
            ], baseGreen: false)

            // Africa
            drawContinent(gc, shapes: [
                (x: 510, y: 190, w: 80, h: 120),
                (x: 500, y: 170, w: 60, h: 50),
                (x: 520, y: 260, w: 50, h: 60),
                (x: 530, y: 220, w: 70, h: 70),
            ], baseGreen: false)

            // Asia
            drawContinent(gc, shapes: [
                (x: 620, y: 100, w: 170, h: 90),
                (x: 600, y: 130, w: 100, h: 60),
                (x: 700, y: 80, w: 90, h: 50),
                (x: 650, y: 160, w: 80, h: 40),    // India
                (x: 740, y: 140, w: 60, h: 50),    // SE Asia
            ], baseGreen: true)

            // Australia
            drawContinent(gc, shapes: [
                (x: 790, y: 290, w: 80, h: 55),
                (x: 800, y: 280, w: 60, h: 40),
            ], baseGreen: false)

            // Antarctica (white)
            UIColor(red: 0.85, green: 0.9, blue: 0.95, alpha: 0.9).setFill()
            gc.fillEllipse(in: CGRect(x: 0, y: CGFloat(h - 45), width: CGFloat(w), height: 55))

            // Arctic ice cap
            UIColor(red: 0.88, green: 0.92, blue: 0.96, alpha: 0.8).setFill()
            gc.fillEllipse(in: CGRect(x: 200, y: -15, width: CGFloat(w - 400), height: 40))

            // Subtle terrain noise on continents
            for _ in 0..<150 {
                let nx = CGFloat.random(in: 0...CGFloat(w))
                let ny = CGFloat.random(in: 50...CGFloat(h - 50))
                let ns = CGFloat.random(in: 3...10)
                let green = CGFloat.random(in: 0.2...0.5)
                let brown = CGFloat.random(in: 0.15...0.35)
                UIColor(red: brown, green: green, blue: 0.05, alpha: 0.15).setFill()
                gc.fillEllipse(in: CGRect(x: nx, y: ny, width: ns, height: ns))
            }
        }
    }

    /// Helper to draw a continent as overlapping ellipses.
    private func drawContinent(_ gc: CGContext, shapes: [(x: Int, y: Int, w: Int, h: Int)], baseGreen: Bool) {
        for shape in shapes {
            // Base color — green forest or brown/tan
            if baseGreen {
                let g = CGFloat.random(in: 0.35...0.55)
                UIColor(red: 0.15, green: g, blue: 0.1, alpha: 1).setFill()
            } else {
                let r = CGFloat.random(in: 0.45...0.6)
                let g = CGFloat.random(in: 0.3...0.45)
                UIColor(red: r, green: g, blue: 0.15, alpha: 1).setFill()
            }
            gc.fillEllipse(in: CGRect(x: shape.x, y: shape.y, width: shape.w, height: shape.h))

            // Terrain variation
            let varCount = max(2, (shape.w * shape.h) / 800)
            for _ in 0..<varCount {
                let vx = CGFloat(shape.x) + CGFloat.random(in: 0...CGFloat(shape.w))
                let vy = CGFloat(shape.y) + CGFloat.random(in: 0...CGFloat(shape.h))
                let vs = CGFloat.random(in: 8...25)
                if Bool.random() {
                    UIColor(red: 0.5, green: 0.35, blue: 0.15, alpha: 0.5).setFill()
                } else {
                    UIColor(red: 0.1, green: CGFloat.random(in: 0.4...0.6), blue: 0.08, alpha: 0.5).setFill()
                }
                gc.fillEllipse(in: CGRect(x: vx, y: vy, width: vs, height: vs * 0.7))
            }
        }
    }

    /// Subtle glow on the night side.
    private func generateEarthEmission() -> UIImage {
        let w = 512
        let h = 256
        let size = CGSize(width: w, height: h)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let gc = ctx.cgContext
            // Very dark base
            UIColor(red: 0.01, green: 0.02, blue: 0.06, alpha: 1).setFill()
            gc.fill(CGRect(origin: .zero, size: size))

            // Tiny city-light dots
            for _ in 0..<80 {
                let cx = CGFloat.random(in: 0...CGFloat(w))
                let cy = CGFloat.random(in: 40...CGFloat(h - 40))
                let cs = CGFloat.random(in: 1...3)
                UIColor(red: 1, green: 0.9, blue: 0.5, alpha: CGFloat.random(in: 0.1...0.35)).setFill()
                gc.fillEllipse(in: CGRect(x: cx, y: cy, width: cs, height: cs))
            }
        }
    }

    /// Generates a procedural cloud texture.
    private func generateCloudTexture() -> UIImage {
        let w = 1024
        let h = 512
        let size = CGSize(width: w, height: h)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let gc = ctx.cgContext
            // Transparent base
            UIColor.clear.setFill()
            gc.fill(CGRect(origin: .zero, size: size))

            // Cloud wisps
            for _ in 0..<60 {
                let cx = CGFloat.random(in: 0...CGFloat(w))
                let cy = CGFloat.random(in: 30...CGFloat(h - 30))
                let cw = CGFloat.random(in: 40...160)
                let ch = CGFloat.random(in: 15...40)
                UIColor(white: 1, alpha: CGFloat.random(in: 0.08...0.25)).setFill()
                gc.fillEllipse(in: CGRect(x: cx - cw/2, y: cy - ch/2, width: cw, height: ch))
            }
        }
    }

    private func createGround() {
        // Invisible ground plane to catch objects
        let groundGeometry = SCNFloor()
        let groundMaterial = SCNMaterial()
        groundMaterial.diffuse.contents = UIColor.clear
        groundGeometry.materials = [groundMaterial]
        let ground = SCNNode(geometry: groundGeometry)
        ground.position = SCNVector3(0, -5.2, 0)
        ground.physicsBody = SCNPhysicsBody.static()
        ground.physicsBody?.restitution = 0.4
        scene.rootNode.addChildNode(ground)
    }

    func dropObject(type: ObjectType) {
        let geometry: SCNGeometry
        let color: UIColor

        switch type {
        case .sphere:
            geometry = SCNSphere(radius: 0.3)
            color = UIColor(red: 1.0, green: 0.3, blue: 0.4, alpha: 1.0)
        case .box:
            geometry = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0.05)
            color = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
        case .cylinder:
            geometry = SCNCylinder(radius: 0.2, height: 0.5)
            color = UIColor(red: 0.2, green: 0.9, blue: 0.6, alpha: 1.0)
        }

        let material = SCNMaterial()
        material.diffuse.contents = color
        material.specular.contents = UIColor.white
        material.shininess = 0.5
        geometry.materials = [material]

        let node = SCNNode(geometry: geometry)
        let randomX = Float.random(in: -2...2)
        let randomZ = Float.random(in: -1...1)
        node.position = SCNVector3(randomX, 8, randomZ)
        node.physicsBody = SCNPhysicsBody.dynamic()
        node.physicsBody?.mass = CGFloat.random(in: 0.5...5.0) // Different masses
        node.physicsBody?.restitution = 0.3

        // Force vector arrow
        let arrowNode = createForceVector(color: UIColor(red: 1.0, green: 1.0, blue: 0.3, alpha: 0.8))
        arrowNode.name = "forceArrow"
        node.addChildNode(arrowNode)

        scene.rootNode.addChildNode(node)
        droppedObjects.append(node)

        // Remove old objects if too many
        if droppedObjects.count > 15 {
            let old = droppedObjects.removeFirst()
            old.removeFromParentNode()
        }
    }

    private func createForceVector(color: UIColor) -> SCNNode {
        let parent = SCNNode()

        let cylinder = SCNCylinder(radius: 0.03, height: 0.8)
        let cylMat = SCNMaterial()
        cylMat.diffuse.contents = color
        cylMat.emission.contents = color
        cylinder.materials = [cylMat]
        let cylNode = SCNNode(geometry: cylinder)
        cylNode.position = SCNVector3(0, -0.6, 0)
        parent.addChildNode(cylNode)

        let cone = SCNCone(topRadius: 0, bottomRadius: 0.08, height: 0.2)
        let coneMat = SCNMaterial()
        coneMat.diffuse.contents = color
        coneMat.emission.contents = color
        cone.materials = [coneMat]
        let coneNode = SCNNode(geometry: cone)
        coneNode.position = SCNVector3(0, -1.1, 0)
        parent.addChildNode(coneNode)

        return parent
    }

    func setGravity(_ g: Double) {
        scene.physicsWorld.gravity = SCNVector3(0, -g, 0)
    }

    func resetObjects() {
        for obj in droppedObjects {
            obj.removeFromParentNode()
        }
        droppedObjects.removeAll()
    }
}
