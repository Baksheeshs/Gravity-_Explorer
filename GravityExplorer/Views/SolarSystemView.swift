import SwiftUI
import SceneKit
import SpriteKit

// MARK: - Extension for math
extension SCNVector3 {
    func length() -> Float {
        return sqrt(x*x + y*y + z*z)
    }
    func normalized() -> SCNVector3 {
        let len = length()
        return len > 0 ? SCNVector3(x/len, y/len, z/len) : SCNVector3(0,0,0)
    }
    static func -(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        return SCNVector3(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    }
    static func +(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        return SCNVector3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }
    static func *(vector: SCNVector3, scalar: Float) -> SCNVector3 {
        return SCNVector3(vector.x * scalar, vector.y * scalar, vector.z * scalar)
    }
}

// MARK: - Solar System Sandbox View
struct SolarSystemView: View {
    @StateObject private var sceneController = SolarSystemSceneController()
    @State private var selectedPlanetIndex: Int = 0
    @State private var isPaused = true
    @State private var showInfo = false
    
    // Sliders for the selected planet
    @State private var massMultiplier: Double = 1.0
    @State private var distanceMultiplier: Double = 1.0
    @State private var radiusMultiplier: Double = 1.0
    @State private var speedMultiplier: Double = 1.0
    
    // Collision flash overlay
    @State private var showCollisionFlash = false

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Solar System Sandbox")
                        .font(Theme.title(22))
                        .foregroundColor(.white)
                    Spacer()
                    
                    // Speed indicator
                    Text("\(speedMultiplier, specifier: "%.1f")×")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Theme.auroraGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Capsule())
                    
                    Button {
                        isPaused.toggle()
                        sceneController.setPaused(isPaused)
                        HapticManager.shared.selection()
                    } label: {
                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Theme.starGlow)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    Button {
                        sceneController.resetSystem()
                        massMultiplier = 1.0
                        distanceMultiplier = 1.0
                        radiusMultiplier = 1.0
                        speedMultiplier = 1.0
                        isPaused = true
                        HapticManager.shared.notification(.warning)
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 20))
                            .foregroundColor(Theme.plasmaRed)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    InfoButton(accentColor: Theme.cosmicCyan) {
                        withAnimation { showInfo.toggle() }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)

                // 3D Scene
                ZStack {
                    SceneView(
                        scene: sceneController.scene,
                        pointOfView: sceneController.cameraNode,
                        options: [.allowsCameraControl, .autoenablesDefaultLighting],
                        delegate: sceneController
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    // Collision flash overlay
                    if showCollisionFlash {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.orange.opacity(0.3))
                            .allowsHitTesting(false)
                            .transition(.opacity)
                    }
                }
                .padding(.horizontal, 12)
                
                // Controls Panel
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 14) {
                        
                        // Planet Selector
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(0..<planets.count, id: \.self) { i in
                                    planetButton(index: i)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // Parameter Sliders
                        VStack(spacing: 10) {
                            // Mass
                            parameterSlider(
                                title: "Mass",
                                value: $massMultiplier,
                                range: 0.1...10.0,
                                step: 0.1,
                                color: Theme.solarOrange,
                                icon: "scalemass.fill"
                            ) { newValue in
                                sceneController.updatePlanetMass(index: selectedPlanetIndex, multiplier: Float(newValue))
                            }
                            
                            // Distance
                            parameterSlider(
                                title: "Distance",
                                value: $distanceMultiplier,
                                range: 0.3...3.0,
                                step: 0.1,
                                color: Theme.cosmicCyan,
                                icon: "arrow.left.and.right"
                            ) { newValue in
                                sceneController.updatePlanetDistance(index: selectedPlanetIndex, multiplier: Float(newValue))
                            }
                            
                            // Radius
                            parameterSlider(
                                title: "Radius",
                                value: $radiusMultiplier,
                                range: 0.5...5.0,
                                step: 0.1,
                                color: Theme.starGlow,
                                icon: "circle.dashed"
                            ) { newValue in
                                sceneController.updatePlanetRadius(index: selectedPlanetIndex, multiplier: Float(newValue))
                            }
                            
                            // Simulation Speed
                            parameterSlider(
                                title: "Speed",
                                value: $speedMultiplier,
                                range: 0.25...4.0,
                                step: 0.25,
                                color: Theme.auroraGreen,
                                icon: "gauge.with.dots.needle.67percent"
                            ) { newValue in
                                sceneController.setTimeScale(Float(newValue))
                            }
                        }
                        .padding(14)
                        .glassCard(cornerRadius: 16)
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 10)
                }
                .frame(maxHeight: 260)
            }

            EducationalOverlay(
                title: "Orbital Mechanics",
                description: "Planets stay in orbit because their speed perfectly balances the Sun's gravity. Adjust mass, distance, or radius — watch orbits destabilize, planets collide, or get flung into space! Enable sound to hear collision booms.",
                icon: "sun.dust.fill",
                accentColor: Theme.cosmicCyan,
                isVisible: $showInfo
            )
        }
        .onAppear {
            sceneController.setupSystem()
            AudioManager.shared.playSpaceAmbient()
        }
        .onDisappear {
            AudioManager.shared.stop()
        }
        .onChange(of: sceneController.lastCollisionEvent?.id) { _ in
            // Flash the screen on collision
            withAnimation(.easeIn(duration: 0.05)) {
                showCollisionFlash = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showCollisionFlash = false
                }
            }
        }
    }
    
    // MARK: - Planet Selector Button
    
    private func planetButton(index: Int) -> some View {
        let planet = planets[index]
        let isSelected = selectedPlanetIndex == index
        return Button {
            withAnimation(.spring(response: 0.3)) {
                selectedPlanetIndex = index
                massMultiplier = 1.0
                distanceMultiplier = 1.0
                radiusMultiplier = 1.0
            }
            HapticManager.shared.selection()
        } label: {
            VStack(spacing: 5) {
                Image(systemName: planet.icon)
                    .font(.system(size: 18))
                    .foregroundColor(planet.color)
                Text(planet.name)
                    .font(Theme.caption(9))
                    .foregroundColor(isSelected ? .white : Theme.dimText)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(isSelected ? Color.white.opacity(0.12) : Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? planet.color.opacity(0.5) : .clear, lineWidth: 1)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
    }
    
    // MARK: - Reusable Parameter Slider
    
    private func parameterSlider(
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double,
        color: Color,
        icon: String,
        onChange: @escaping (Double) -> Void
    ) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundColor(color.opacity(0.7))
                Text(title)
                    .font(Theme.body(13))
                    .foregroundColor(Theme.secondaryText)
                Spacer()
                Text("\(value.wrappedValue, specifier: "%.1f")×")
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundColor(color)
            }
            Slider(value: Binding(
                get: { value.wrappedValue },
                set: { newValue in
                    value.wrappedValue = newValue
                    onChange(newValue)
                    HapticManager.shared.parameterChanged()
                }
            ), in: range, step: step)
            .tint(color)
        }
    }
}
