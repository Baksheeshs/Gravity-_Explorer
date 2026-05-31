import SceneKit
import SwiftUI
import UIKit

// MARK: - Procedural Planet Texture Generator

extension UIColor {
    func generatePlanetTexture(style: PlanetTextureStyle = .rocky) -> UIImage {
        let size = CGSize(width: 512, height: 512)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
        
        // Base color fill
        self.setFill()
        context.fill(CGRect(origin: .zero, size: size))
        
        switch style {
        case .rocky:
            // Mercury-like: heavily cratered grey surface
            for _ in 0..<120 {
                let x = CGFloat.random(in: 0...512)
                let y = CGFloat.random(in: 0...512)
                let r = CGFloat.random(in: 3...25)
                let alpha = CGFloat.random(in: 0.08...0.3)
                UIColor.black.withAlphaComponent(alpha).setFill()
                context.fillEllipse(in: CGRect(x: x, y: y, width: r, height: r))
                // Crater rim highlight
                UIColor.white.withAlphaComponent(alpha * 0.4).setFill()
                context.fillEllipse(in: CGRect(x: x - 1, y: y - 1, width: r * 0.4, height: r * 0.4))
            }
            
        case .volcanic:
            // Venus-like: thick clouds, swirling yellows and oranges
            for _ in 0..<25 {
                let y = CGFloat.random(in: 0...512)
                let height = CGFloat.random(in: 15...60)
                let alpha = CGFloat.random(in: 0.08...0.2)
                UIColor(red: 1.0, green: 0.85, blue: 0.5, alpha: alpha).setFill()
                context.fill(CGRect(x: 0, y: y, width: 512, height: height))
            }
            for _ in 0..<15 {
                let x = CGFloat.random(in: 0...512)
                let y = CGFloat.random(in: 0...512)
                let w = CGFloat.random(in: 40...150)
                let h = CGFloat.random(in: 15...40)
                UIColor(red: 0.95, green: 0.65, blue: 0.2, alpha: CGFloat.random(in: 0.1...0.2)).setFill()
                context.fillEllipse(in: CGRect(x: x, y: y, width: w, height: h))
            }
            
        case .oceanic:
            // Earth-like: blue oceans with green-brown continents and white clouds
            // Continents
            for _ in 0..<8 {
                let x = CGFloat.random(in: 0...512)
                let y = CGFloat.random(in: 0...512)
                let r = CGFloat.random(in: 40...130)
                UIColor(red: 0.3, green: 0.55, blue: 0.2, alpha: CGFloat.random(in: 0.3...0.5)).setFill()
                context.fillEllipse(in: CGRect(x: x - r/2, y: y - r/2, width: r, height: r * 0.7))
            }
            for _ in 0..<5 {
                let x = CGFloat.random(in: 0...512)
                let y = CGFloat.random(in: 0...512)
                let r = CGFloat.random(in: 30...80)
                UIColor(red: 0.6, green: 0.45, blue: 0.25, alpha: CGFloat.random(in: 0.2...0.35)).setFill()
                context.fillEllipse(in: CGRect(x: x, y: y, width: r, height: r * 0.6))
            }
            // Cloud wisps
            for _ in 0..<20 {
                let x = CGFloat.random(in: 0...512)
                let y = CGFloat.random(in: 0...512)
                let w = CGFloat.random(in: 30...120)
                UIColor.white.withAlphaComponent(CGFloat.random(in: 0.1...0.25)).setFill()
                context.fillEllipse(in: CGRect(x: x, y: y, width: w, height: CGFloat.random(in: 5...15)))
            }
            // Polar ice caps
            UIColor.white.withAlphaComponent(0.3).setFill()
            context.fillEllipse(in: CGRect(x: 128, y: -20, width: 256, height: 60))
            context.fillEllipse(in: CGRect(x: 128, y: 472, width: 256, height: 60))
            
        case .desert:
            // Mars-like: rusty red-orange with polar caps and canyons
            for _ in 0..<60 {
                let x = CGFloat.random(in: 0...512)
                let y = CGFloat.random(in: 0...512)
                let r = CGFloat.random(in: 5...30)
                UIColor(red: 0.5, green: 0.2, blue: 0.08, alpha: CGFloat.random(in: 0.1...0.3)).setFill()
                context.fillEllipse(in: CGRect(x: x, y: y, width: r, height: r))
            }
            // Dark regions (Syrtis Major style)
            for _ in 0..<6 {
                let x = CGFloat.random(in: 50...400)
                let y = CGFloat.random(in: 100...400)
                let r = CGFloat.random(in: 40...100)
                UIColor(red: 0.35, green: 0.15, blue: 0.05, alpha: 0.2).setFill()
                context.fillEllipse(in: CGRect(x: x, y: y, width: r, height: r * 0.8))
            }
            // Polar caps
            UIColor.white.withAlphaComponent(0.35).setFill()
            context.fillEllipse(in: CGRect(x: 160, y: -15, width: 192, height: 50))
            context.fillEllipse(in: CGRect(x: 180, y: 477, width: 152, height: 45))
            
        case .gasGiant:
            // Jupiter-like: many horizontal bands with storm spots
            for _ in 0..<45 {
                let y = CGFloat.random(in: 0...512)
                let height = CGFloat.random(in: 6...40)
                let alpha = CGFloat.random(in: 0.06...0.25)
                let hue = CGFloat.random(in: 0...1)
                (hue < 0.5 ? UIColor.white : UIColor(red: 0.6, green: 0.3, blue: 0.1, alpha: 1.0))
                    .withAlphaComponent(alpha).setFill()
                context.fill(CGRect(x: 0, y: y, width: 512, height: height))
            }
            // Great Red Spot style storms
            for _ in 0..<6 {
                let x = CGFloat.random(in: 80...430)
                let y = CGFloat.random(in: 80...430)
                let w = CGFloat.random(in: 25...70)
                let h = CGFloat.random(in: 15...35)
                UIColor(red: 0.85, green: 0.45, blue: 0.2, alpha: CGFloat.random(in: 0.15...0.3)).setFill()
                context.fillEllipse(in: CGRect(x: x, y: y, width: w, height: h))
            }
            
        case .ringedGiant:
            // Saturn-like: softer bands, more golden
            for _ in 0..<35 {
                let y = CGFloat.random(in: 0...512)
                let height = CGFloat.random(in: 8...35)
                let alpha = CGFloat.random(in: 0.05...0.2)
                (Bool.random() ? UIColor(red: 0.95, green: 0.85, blue: 0.6, alpha: 1.0) : UIColor(red: 0.6, green: 0.5, blue: 0.3, alpha: 1.0))
                    .withAlphaComponent(alpha).setFill()
                context.fill(CGRect(x: 0, y: y, width: 512, height: height))
            }
            for _ in 0..<4 {
                let x = CGFloat.random(in: 100...400)
                let y = CGFloat.random(in: 100...400)
                let w = CGFloat.random(in: 30...60)
                UIColor.white.withAlphaComponent(0.1).setFill()
                context.fillEllipse(in: CGRect(x: x, y: y, width: w, height: w * 0.5))
            }
            
        case .iceGiant:
            // Uranus/Neptune: smooth with subtle banding and a few bright clouds
            for _ in 0..<15 {
                let y = CGFloat.random(in: 0...512)
                let height = CGFloat.random(in: 5...25)
                UIColor.white.withAlphaComponent(CGFloat.random(in: 0.04...0.12)).setFill()
                context.fill(CGRect(x: 0, y: y, width: 512, height: height))
            }
            // Bright cloud streaks
            for _ in 0..<8 {
                let x = CGFloat.random(in: 50...460)
                let y = CGFloat.random(in: 50...460)
                let w = CGFloat.random(in: 20...80)
                UIColor.white.withAlphaComponent(CGFloat.random(in: 0.08...0.18)).setFill()
                context.fillEllipse(in: CGRect(x: x, y: y, width: w, height: CGFloat.random(in: 5...12)))
            }
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}

enum PlanetTextureStyle {
    case rocky, volcanic, oceanic, desert, gasGiant, ringedGiant, iceGiant
}

// MARK: - Simulation Constants

let G_SIMULATION: Float = 0.05
let SUN_MASS: Float = 1000.0
let TIME_STEP: Float = 1.0 / 60.0
let SOFTENING: Float = 2.5 // Prevents extreme forces at close range
let COLLISION_COOLDOWN: TimeInterval = 0.3

// MARK: - Collision Event (published to the View)

struct CollisionEvent: Identifiable {
    let id = UUID()
    let position: SCNVector3
    let type: CollisionType
    let planetName: String
    let timestamp: Date = Date()
    
    enum CollisionType {
        case planetSun
        case planetPlanet
    }
}

// MARK: - Planet Node (Manual Physics)

class PlanetNode: SCNNode {
    var planetData: PlanetData
    var velocity: SCNVector3
    var baseMass: Float
    var baseVisualRadius: Float
    var massMultiplier: Float = 1.0
    var radiusMultiplier: Float = 1.0
    var baseDistance: Float
    
    // Trail handling
    var maxTrailPoints = 250
    var trailNode: SCNNode?
    var trailPositions: [SCNVector3] = []
    
    // Orbit guide
    var orbitGuideNode: SCNNode?
    
    var currentMass: Float {
        return baseMass * massMultiplier
    }
    
    var collisionRadius: Float {
        return baseVisualRadius * radiusMultiplier
    }
    
    var textureStyle: PlanetTextureStyle
    
    init(data: PlanetData, initialVelocity: SCNVector3, distance: Float) {
        self.planetData = data
        self.velocity = initialVelocity
        self.baseMass = Float(data.mass / 1e27) // Scale mass down (Jupiter ~1.9 vs Sun 1000)
        self.baseDistance = distance
        
        // Determine texture style based on planet
        switch data.name {
        case "Mercury":
            self.textureStyle = .rocky
        case "Venus":
            self.textureStyle = .volcanic
        case "Earth":
            self.textureStyle = .oceanic
        case "Mars":
            self.textureStyle = .desert
        case "Jupiter":
            self.textureStyle = .gasGiant
        case "Saturn":
            self.textureStyle = .ringedGiant
        case "Uranus", "Neptune":
            self.textureStyle = .iceGiant
        default:
            self.textureStyle = .rocky
        }
        
        // Scale radius for visibility — clamp to reasonable range
        let scaledRadius = max(min(Float(data.radius / 1e6) * 0.7, 4.0), 0.8)
        self.baseVisualRadius = scaledRadius
        
        super.init()
        
        let sphere = SCNSphere(radius: CGFloat(scaledRadius))
        sphere.segmentCount = 48
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(data.color).generatePlanetTexture(style: textureStyle)
        material.specular.contents = UIColor.white
        material.shininess = 0.4
        material.roughness.contents = NSNumber(value: 0.6)
        sphere.materials = [material]
        self.geometry = sphere
        
        self.name = data.name
        
        // Add self-rotation
        let rotationDuration = Double.random(in: 4...12)
        let rotateAction = SCNAction.repeatForever(
            SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: rotationDuration)
        )
        self.runAction(rotateAction, forKey: "selfRotation")
        
        // Add subtle glow
        addGlow(color: UIColor(data.color))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addGlow(color: UIColor) {
        let glowSphere = SCNSphere(radius: CGFloat(baseVisualRadius * 1.15))
        let glowMat = SCNMaterial()
        glowMat.diffuse.contents = UIColor.clear
        glowMat.emission.contents = color.withAlphaComponent(0.15)
        glowMat.isDoubleSided = true
        glowMat.writesToDepthBuffer = false
        glowSphere.materials = [glowMat]
        let glowNode = SCNNode(geometry: glowSphere)
        glowNode.name = "glow"
        self.addChildNode(glowNode)
    }
    
    func updateVisualRadius() {
        guard let sphere = self.geometry as? SCNSphere else { return }
        let newRadius = CGFloat(baseVisualRadius * radiusMultiplier)
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.3
        sphere.radius = newRadius
        // Update glow too
        if let glowNode = childNode(withName: "glow", recursively: false),
           let glowSphere = glowNode.geometry as? SCNSphere {
            glowSphere.radius = newRadius * 1.15
        }
        SCNTransaction.commit()
    }
    
    // Update the trail path based on current position
    func updateTrail() {
        trailPositions.append(self.position)
        if trailPositions.count > maxTrailPoints {
            trailPositions.removeFirst()
        }
        
        guard trailPositions.count > 2 else { return }
        
        // Build lines
        var indices: [Int32] = []
        for i in 0..<(trailPositions.count - 1) {
            indices.append(Int32(i))
            indices.append(Int32(i + 1))
        }
        
        let source = SCNGeometrySource(vertices: trailPositions)
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        
        let geo = SCNGeometry(sources: [source], elements: [element])
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor(planetData.color).withAlphaComponent(0.4)
        mat.emission.contents = UIColor(planetData.color).withAlphaComponent(0.3)
        mat.isDoubleSided = true
        geo.materials = [mat]
        
        if trailNode == nil {
            trailNode = SCNNode(geometry: geo)
            self.parent?.addChildNode(trailNode!)
        } else {
            trailNode?.geometry = geo
        }
    }
    
    func resetTrail() {
        trailPositions.removeAll()
        trailNode?.removeFromParentNode()
        trailNode = nil
    }
    
    func createOrbitGuide(in parentNode: SCNNode) {
        orbitGuideNode?.removeFromParentNode()
        
        let segments = 120
        var positions: [SCNVector3] = []
        var indices: [Int32] = []
        
        for i in 0...segments {
            let angle = Float(i) / Float(segments) * 2.0 * .pi
            let x = baseDistance * cos(angle)
            let z = baseDistance * sin(angle)
            positions.append(SCNVector3(x, 0, z))
        }
        
        for i in 0..<segments {
            indices.append(Int32(i))
            indices.append(Int32(i + 1))
        }
        
        let source = SCNGeometrySource(vertices: positions)
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        let geo = SCNGeometry(sources: [source], elements: [element])
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor(planetData.color).withAlphaComponent(0.12)
        mat.emission.contents = UIColor(planetData.color).withAlphaComponent(0.08)
        mat.isDoubleSided = true
        geo.materials = [mat]
        
        let guideNode = SCNNode(geometry: geo)
        parentNode.addChildNode(guideNode)
        self.orbitGuideNode = guideNode
    }
}

// MARK: - Solar System Scene Controller

class SolarSystemSceneController: NSObject, ObservableObject, @unchecked Sendable, @preconcurrency SCNSceneRendererDelegate {
    let scene: SCNScene
    let cameraNode: SCNNode
    
    var sunNode: SCNNode!
    var sunCoronaNode: SCNNode?
    var planetNodes: [PlanetNode] = []
    
    @Published var isSimulationPaused = true
    @Published var lastCollisionEvent: CollisionEvent?
    
    var timeScale: Float = 1.0
    private var lastCollisionTime: TimeInterval = 0
    private var lastUpdateTime: TimeInterval = 0
    
    override init() {
        scene = SCNScene()
        scene.background.contents = UIColor(red: 0.0, green: 0.0, blue: 0.01, alpha: 1.0) // Near-pure black space
        
        // No SceneKit gravity — we handle everything manually
        scene.physicsWorld.gravity = SCNVector3Zero
        
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zFar = 600
        cameraNode.camera?.fieldOfView = 60
        cameraNode.camera?.wantsHDR = true
        cameraNode.camera?.bloomIntensity = 0.6
        cameraNode.camera?.bloomThreshold = 0.7
        cameraNode.position = SCNVector3(0, 100, 70) // Pulled back further for 8 planets
        cameraNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(cameraNode)
        
        super.init()
    }
    
    func setupSystem() {
        // Clear old nodes
        scene.rootNode.childNodes.forEach {
            if $0 != cameraNode { $0.removeFromParentNode() }
        }
        planetNodes.removeAll()
        lastUpdateTime = 0
        
        createSun()
        createPlanets()
        addBackgroundStars()
    }
    
    // MARK: - Sun Creation
    
    private func createSun() {
        let sunRadius: CGFloat = 4.0
        let sunGeo = SCNSphere(radius: sunRadius)
        sunGeo.segmentCount = 64
        
        let sunMat = SCNMaterial()
        sunMat.diffuse.contents = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0)
        sunMat.emission.contents = UIColor(red: 1.0, green: 0.7, blue: 0.15, alpha: 1.0)
        sunMat.lightingModel = .constant
        sunGeo.materials = [sunMat]
        
        sunNode = SCNNode(geometry: sunGeo)
        sunNode.position = SCNVector3Zero
        sunNode.name = "Sun"
        
        // Self rotation
        let rotateAction = SCNAction.repeatForever(
            SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 20)
        )
        sunNode.runAction(rotateAction, forKey: "sunRotation")
        
        // Corona glow (pulsating outer shell)
        let coronaGeo = SCNSphere(radius: sunRadius * 1.35)
        coronaGeo.segmentCount = 48
        let coronaMat = SCNMaterial()
        coronaMat.diffuse.contents = UIColor.clear
        coronaMat.emission.contents = UIColor(red: 1.0, green: 0.6, blue: 0.1, alpha: 0.25)
        coronaMat.isDoubleSided = true
        coronaMat.writesToDepthBuffer = false
        coronaMat.transparencyMode = .rgbZero
        coronaGeo.materials = [coronaMat]
        
        sunCoronaNode = SCNNode(geometry: coronaGeo)
        sunNode.addChildNode(sunCoronaNode!)
        
        // Pulsating corona animation
        let pulseUp = SCNAction.scale(to: 1.15, duration: 2.0)
        pulseUp.timingMode = .easeInEaseOut
        let pulseDown = SCNAction.scale(to: 0.95, duration: 2.0)
        pulseDown.timingMode = .easeInEaseOut
        sunCoronaNode?.runAction(SCNAction.repeatForever(SCNAction.sequence([pulseUp, pulseDown])))
        
        // Main light from the sun
        let omniLight = SCNNode()
        omniLight.light = SCNLight()
        omniLight.light?.type = .omni
        omniLight.light?.color = UIColor(red: 1.0, green: 0.95, blue: 0.85, alpha: 1.0)
        omniLight.light?.intensity = 2500
        omniLight.light?.attenuationStartDistance = 0
        omniLight.light?.attenuationEndDistance = 200
        sunNode.addChildNode(omniLight)
        
        // Subtle ambient light
        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 40
        ambient.light?.color = UIColor(red: 0.2, green: 0.2, blue: 0.35, alpha: 1.0)
        scene.rootNode.addChildNode(ambient)
        
        scene.rootNode.addChildNode(sunNode)
    }
    
    // MARK: - Saturn Rings
    
    private func addSaturnRings(to planetNode: PlanetNode) {
        let innerRadius = CGFloat(planetNode.baseVisualRadius * 1.4)
        let outerRadius = CGFloat(planetNode.baseVisualRadius * 2.6)
        
        // Create a flat torus for the ring
        let ringGeo = SCNTorus(ringRadius: (innerRadius + outerRadius) / 2.0, pipeRadius: (outerRadius - innerRadius) / 2.0)
        ringGeo.ringSegmentCount = 64
        ringGeo.pipeSegmentCount = 8
        
        let ringMat = SCNMaterial()
        ringMat.diffuse.contents = UIColor(red: 0.85, green: 0.75, blue: 0.55, alpha: 0.5)
        ringMat.emission.contents = UIColor(red: 0.6, green: 0.5, blue: 0.35, alpha: 0.15)
        ringMat.isDoubleSided = true
        ringMat.transparencyMode = .dualLayer
        ringGeo.materials = [ringMat]
        
        let ringNode = SCNNode(geometry: ringGeo)
        ringNode.scale = SCNVector3(1.0, 0.02, 1.0) // Flatten to a disc
        ringNode.eulerAngles.x = Float.pi * 0.15 // Slight tilt (like Saturn's 26.7° axial tilt)
        ringNode.name = "saturnRing"
        planetNode.addChildNode(ringNode)
    }
    
    // MARK: - Create Planets (Spread at Random Angles)
    
    private func createPlanets() {
        let angleSpread = (2.0 * Float.pi) / Float(planets.count)
        
        // Distances that give good visual spacing for 8 planets
        let baseDistances: [Float] = [10, 16, 22, 28, 38, 50, 62, 74]
        
        for (i, p) in planets.enumerated() {
            let distance = i < baseDistances.count ? baseDistances[i] : Float(i + 1) * 9.0 + 6.0
            
            // Spread planets evenly around the sun to avoid gravitational lineup
            let angle = angleSpread * Float(i) + Float.random(in: -0.2...0.2)
            let x = distance * cos(angle)
            let z = distance * sin(angle)
            
            // Circular orbit velocity: v = sqrt(G * M_sun / r)
            let orbitSpeed = sqrt((G_SIMULATION * SUN_MASS) / distance)
            
            // Tangent velocity perpendicular to radial direction (counter-clockwise)
            let vx = -orbitSpeed * sin(angle)
            let vz = orbitSpeed * cos(angle)
            
            let pNode = PlanetNode(data: p, initialVelocity: SCNVector3(vx, 0, vz), distance: distance)
            pNode.position = SCNVector3(x, 0, z)
            
            scene.rootNode.addChildNode(pNode)
            planetNodes.append(pNode)
            
            // Add Saturn's rings
            if p.name == "Saturn" {
                addSaturnRings(to: pNode)
            }
            
            // Create orbit guide ring
            pNode.createOrbitGuide(in: scene.rootNode)
        }
    }
    
    // MARK: - Background Stars
    
    private func addBackgroundStars() {
        for _ in 0..<200 {
            let starGeo = SCNSphere(radius: CGFloat.random(in: 0.04...0.18))
            let mat = SCNMaterial()
            let brightness = CGFloat.random(in: 0.6...1.0)
            mat.diffuse.contents = UIColor(white: brightness, alpha: 1.0)
            mat.emission.contents = UIColor(white: brightness, alpha: 1.0)
            mat.lightingModel = .constant
            starGeo.materials = [mat]
            let star = SCNNode(geometry: starGeo)
            
            let radius = Float.random(in: 120...250)
            let theta = Float.random(in: 0...(2 * .pi))
            let phi = Float.random(in: 0...(.pi))
            
            star.position = SCNVector3(
                radius * sin(phi) * cos(theta),
                radius * cos(phi),
                radius * sin(phi) * sin(theta)
            )
            
            // Some stars twinkle
            if Bool.random() {
                let fadeOut = SCNAction.fadeOpacity(to: CGFloat.random(in: 0.3...0.6), duration: Double.random(in: 1...3))
                let fadeIn = SCNAction.fadeOpacity(to: 1.0, duration: Double.random(in: 1...3))
                star.runAction(SCNAction.repeatForever(SCNAction.sequence([fadeOut, fadeIn])))
            }
            
            scene.rootNode.addChildNode(star)
        }
    }
    
    // MARK: - Simulation Controls
    
    func setPaused(_ paused: Bool) {
        isSimulationPaused = paused
    }
    
    func resetSystem() {
        setupSystem()
        isSimulationPaused = true
    }
    
    func setTimeScale(_ scale: Float) {
        timeScale = max(0.1, min(scale, 4.0))
    }
    
    // MARK: - Parameter Updates
    
    func updatePlanetDistance(index: Int, multiplier: Float) {
        guard index < planetNodes.count else { return }
        let p = planetNodes[index]
        
        let newDistance = p.baseDistance * multiplier
        
        // Get current angle from origin
        let currentPos = p.position
        var normalizedPos = currentPos.normalized()
        if currentPos.length() < 0.1 {
            normalizedPos = SCNVector3(1, 0, 0)
        }
        
        // Move planet to new distance
        let newPos = normalizedPos * newDistance
        p.position = newPos
        
        // Recalculate orbital velocity for new distance
        let orbitSpeed = sqrt((G_SIMULATION * SUN_MASS) / newDistance)
        let angle = atan2(normalizedPos.z, normalizedPos.x)
        p.velocity = SCNVector3(-orbitSpeed * sin(angle), 0, orbitSpeed * cos(angle))
        
        p.resetTrail()
        
        // Update orbit guide
        p.orbitGuideNode?.removeFromParentNode()
        let savedBase = p.baseDistance
        p.baseDistance = newDistance
        p.createOrbitGuide(in: scene.rootNode)
        p.baseDistance = savedBase
    }
    
    func updatePlanetMass(index: Int, multiplier: Float) {
        guard index < planetNodes.count else { return }
        let p = planetNodes[index]
        p.massMultiplier = multiplier
        
        // Scale visual size proportional to cube root of mass change
        let visualScale = pow(multiplier, 1.0 / 3.0)
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.3
        p.scale = SCNVector3(visualScale, visualScale, visualScale)
        SCNTransaction.commit()
    }
    
    func updatePlanetRadius(index: Int, multiplier: Float) {
        guard index < planetNodes.count else { return }
        let p = planetNodes[index]
        p.radiusMultiplier = multiplier
        p.updateVisualRadius()
    }
    
    // MARK: - Render Loop (Velocity-Verlet N-Body Integration)
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard !isSimulationPaused else {
            lastUpdateTime = time
            return
        }
        
        // Calculate dt — cap to prevent huge jumps on first frame or lag spikes
        if lastUpdateTime == 0 { lastUpdateTime = time }
        let rawDt = Float(time - lastUpdateTime)
        let dt = min(rawDt, 1.0 / 60.0) * timeScale
        lastUpdateTime = time
        
        guard dt > 0 else { return }
        
        let sunPos = SCNVector3Zero
        let sunMass = SUN_MASS
        
        // --- Step 1: Compute acceleration at current positions ---
        var accelerations = [SCNVector3](repeating: SCNVector3Zero, count: planetNodes.count)
        
        for i in 0..<planetNodes.count {
            let p = planetNodes[i]
            let pos = p.position
            
            // Gravitational pull from the Sun
            let toSun = sunPos - pos
            let distSun = max(toSun.length(), SOFTENING)
            let accSunMag = G_SIMULATION * sunMass / (distSun * distSun)
            accelerations[i] = accelerations[i] + toSun.normalized() * accSunMag
            
            // Gravitational pull from other planets
            for j in 0..<planetNodes.count {
                if i == j { continue }
                let other = planetNodes[j]
                let toOther = other.position - pos
                let distOther = max(toOther.length(), SOFTENING)
                let accOtherMag = G_SIMULATION * other.currentMass / (distOther * distOther)
                accelerations[i] = accelerations[i] + toOther.normalized() * accOtherMag
            }
        }
        
        // --- Step 2: Update velocities (half-step) and positions ---
        for i in 0..<planetNodes.count {
            let p = planetNodes[i]
            // v(t + dt/2) = v(t) + a(t) * dt/2
            p.velocity = p.velocity + accelerations[i] * (dt / 2.0)
            // x(t + dt) = x(t) + v(t + dt/2) * dt
            p.position = p.position + p.velocity * dt
        }
        
        // --- Step 3: Recompute accelerations at new positions ---
        var newAccelerations = [SCNVector3](repeating: SCNVector3Zero, count: planetNodes.count)
        
        for i in 0..<planetNodes.count {
            let p = planetNodes[i]
            let pos = p.position
            
            let toSun = sunPos - pos
            let distSun = max(toSun.length(), SOFTENING)
            let accSunMag = G_SIMULATION * sunMass / (distSun * distSun)
            newAccelerations[i] = newAccelerations[i] + toSun.normalized() * accSunMag
            
            for j in 0..<planetNodes.count {
                if i == j { continue }
                let other = planetNodes[j]
                let toOther = other.position - pos
                let distOther = max(toOther.length(), SOFTENING)
                let accOtherMag = G_SIMULATION * other.currentMass / (distOther * distOther)
                newAccelerations[i] = newAccelerations[i] + toOther.normalized() * accOtherMag
            }
        }
        
        // --- Step 4: Update velocities (second half-step) ---
        for i in 0..<planetNodes.count {
            let p = planetNodes[i]
            // v(t + dt) = v(t + dt/2) + a(t + dt) * dt/2
            p.velocity = p.velocity + newAccelerations[i] * (dt / 2.0)
        }
        
        // --- Step 5: Collision detection ---
        checkCollisions(at: time)
        
        // --- Step 6: Update trails ---
        for p in planetNodes {
            p.updateTrail()
        }
    }
    
    // MARK: - Collision Detection (Manual Distance-Based)
    
    private func checkCollisions(at time: TimeInterval) {
        guard time - lastCollisionTime > COLLISION_COOLDOWN else { return }
        
        var toRemove: Set<Int> = []
        
        // Planet–Sun collisions
        let sunRadius: Float = 4.0
        for (i, p) in planetNodes.enumerated() {
            let dist = p.position.length()
            if dist < (sunRadius + p.collisionRadius) {
                toRemove.insert(i)
                
                let collisionPos = p.position
                let planetName = p.planetData.name
                let planetColor = UIColor(p.planetData.color)
                
                DispatchQueue.main.async { [weak self] in
                    self?.lastCollisionEvent = CollisionEvent(
                        position: collisionPos,
                        type: .planetSun,
                        planetName: planetName
                    )
                    HapticManager.shared.forceApplied(intensity: 1.0)
                    AudioManager.shared.playCollisionSound()
                }
                
                createExplosion(at: collisionPos, color: planetColor, intensity: .high)
            }
        }
        
        // Planet–Planet collisions
        for i in 0..<planetNodes.count {
            if toRemove.contains(i) { continue }
            for j in (i + 1)..<planetNodes.count {
                if toRemove.contains(j) { continue }
                let a = planetNodes[i]
                let b = planetNodes[j]
                let dist = (a.position - b.position).length()
                
                if dist < (a.collisionRadius + b.collisionRadius) {
                    // Smaller planet is absorbed by larger
                    let (survivor, absorbed) = a.currentMass >= b.currentMass ? (i, j) : (j, i)
                    toRemove.insert(absorbed)
                    
                    let survivorNode = planetNodes[survivor]
                    let absorbedNode = planetNodes[absorbed]
                    
                    // Merge mass
                    survivorNode.massMultiplier += absorbedNode.currentMass / survivorNode.baseMass
                    
                    // Grow the survivor visually
                    let newScale = pow(survivorNode.massMultiplier, 1.0 / 3.0)
                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = 0.4
                    survivorNode.scale = SCNVector3(newScale, newScale, newScale)
                    SCNTransaction.commit()
                    
                    // Momentum conservation
                    let totalMass = survivorNode.currentMass + absorbedNode.currentMass
                    survivorNode.velocity = (survivorNode.velocity * survivorNode.currentMass + absorbedNode.velocity * absorbedNode.currentMass) * (1.0 / totalMass)
                    
                    let absorbedPos = absorbedNode.position
                    let absorbedName = absorbedNode.planetData.name
                    let absorbedColor = UIColor(absorbedNode.planetData.color)
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.lastCollisionEvent = CollisionEvent(
                            position: absorbedPos,
                            type: .planetPlanet,
                            planetName: absorbedName
                        )
                        HapticManager.shared.collision()
                        AudioManager.shared.playMergeSound()
                    }
                    
                    createExplosion(at: absorbedPos, color: absorbedColor, intensity: .medium)
                }
            }
        }
        
        // Remove absorbed planets (in reverse order to keep indices valid)
        if !toRemove.isEmpty {
            lastCollisionTime = time
            for i in toRemove.sorted().reversed() {
                let p = planetNodes[i]
                p.trailNode?.removeFromParentNode()
                p.orbitGuideNode?.removeFromParentNode()
                p.removeFromParentNode()
                planetNodes.remove(at: i)
            }
        }
    }
    
    // MARK: - Explosion Particles
    
    enum ExplosionIntensity {
        case low, medium, high
    }
    
    private func createExplosion(at position: SCNVector3, color: UIColor, intensity: ExplosionIntensity = .medium) {
        let particleSystem = SCNParticleSystem()
        particleSystem.loops = false
        particleSystem.emissionDuration = 0.15
        particleSystem.spreadingAngle = 180
        particleSystem.particleDiesOnCollision = false
        particleSystem.particleLifeSpan = 1.2
        particleSystem.particleLifeSpanVariation = 0.4
        particleSystem.particleSize = 0.4
        particleSystem.particleSizeVariation = 0.2
        particleSystem.particleColor = color
        particleSystem.particleColorVariation = SCNVector4(0.2, 0.2, 0.1, 0)
        
        switch intensity {
        case .low:
            particleSystem.birthRate = 500
            particleSystem.particleVelocity = 8
            particleSystem.particleVelocityVariation = 3
        case .medium:
            particleSystem.birthRate = 1500
            particleSystem.particleVelocity = 12
            particleSystem.particleVelocityVariation = 5
        case .high:
            particleSystem.birthRate = 3000
            particleSystem.particleVelocity = 18
            particleSystem.particleVelocityVariation = 7
        }
        
        let explosionNode = SCNNode()
        explosionNode.position = position
        explosionNode.addParticleSystem(particleSystem)
        scene.rootNode.addChildNode(explosionNode)
        
        // Flash light at explosion point
        let flashLight = SCNLight()
        flashLight.type = .omni
        flashLight.color = color
        flashLight.intensity = 3000
        flashLight.attenuationEndDistance = 50
        explosionNode.light = flashLight
        
        // Fade out flash + auto-remove using SCNAction (stays on SceneKit thread — no Sendable issues)
        let fadeWait  = SCNAction.wait(duration: 0.1)
        let fadeLight = SCNAction.customAction(duration: 0.5) { _, elapsed in
            flashLight.intensity = CGFloat(3000) * CGFloat(1.0 - elapsed / 0.5)
        }
        let removeNode = SCNAction.removeFromParentNode()
        let waitThenRemove = SCNAction.wait(duration: 2.0)
        
        explosionNode.runAction(SCNAction.sequence([
            fadeWait,
            fadeLight,
            waitThenRemove,
            removeNode
        ]))
    }
}
