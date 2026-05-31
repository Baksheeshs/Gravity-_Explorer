import Foundation
import SwiftUI

// MARK: - Universal Gravitational Constant
let universalG: Double = 6.674e-11 // N⋅m²/kg²

// MARK: - Planet Data
struct PlanetData: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let g: Double          // m/s²
    let mass: Double       // kg
    let radius: Double     // meters
    let color: Color
    let icon: String       // SF Symbol

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    static func == (lhs: PlanetData, rhs: PlanetData) -> Bool {
        lhs.name == rhs.name
    }
}

let planets: [PlanetData] = [
    PlanetData(name: "Mercury", g: 3.7,   mass: 3.301e23, radius: 2.440e6,  color: Color(red: 0.55, green: 0.52, blue: 0.50), icon: "circle.fill"),
    PlanetData(name: "Venus",   g: 8.87,  mass: 4.867e24, radius: 6.052e6,  color: Color(red: 0.90, green: 0.75, blue: 0.45), icon: "sun.max.fill"),
    PlanetData(name: "Earth",   g: 9.81,  mass: 5.972e24, radius: 6.371e6,  color: Color(red: 0.18, green: 0.45, blue: 0.85), icon: "globe.americas.fill"),
    PlanetData(name: "Mars",    g: 3.72,  mass: 6.417e23, radius: 3.390e6,  color: Color(red: 0.78, green: 0.30, blue: 0.12), icon: "sparkle"),
    PlanetData(name: "Jupiter", g: 24.79, mass: 1.898e27, radius: 6.991e7,  color: Color(red: 0.72, green: 0.55, blue: 0.35), icon: "hurricane"),
    PlanetData(name: "Saturn",  g: 10.44, mass: 5.683e26, radius: 5.823e7,  color: Color(red: 0.82, green: 0.72, blue: 0.50), icon: "circle.dashed"),
    PlanetData(name: "Uranus",  g: 8.69,  mass: 8.681e25, radius: 2.536e7,  color: Color(red: 0.60, green: 0.82, blue: 0.85), icon: "snowflake"),
    PlanetData(name: "Neptune", g: 11.15, mass: 1.024e26, radius: 2.462e7,  color: Color(red: 0.25, green: 0.38, blue: 0.82), icon: "wind"),
]

// MARK: - Module Definitions
struct ModuleInfo: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
}

let modules: [ModuleInfo] = [
    ModuleInfo(id: 1, title: "What is Gravity?",       subtitle: "Discover the invisible force",   icon: "globe.americas.fill",       accentColor: Theme.starGlow),
    ModuleInfo(id: 2, title: "Capital G vs Small g",   subtitle: "Constants & acceleration",       icon: "scalemass.fill",            accentColor: Theme.solarOrange),
    ModuleInfo(id: 3, title: "Acceleration",            subtitle: "Free fall experiments",          icon: "arrow.down.to.line.compact",accentColor: Theme.auroraGreen),
    ModuleInfo(id: 4, title: "Zero Gravity",            subtitle: "Float in space",                 icon: "airplane.departure",        accentColor: Theme.cosmicCyan),
    ModuleInfo(id: 5, title: "Gravity & Body",          subtitle: "Forces on you",                  icon: "figure.stand",              accentColor: Theme.plasmaRed),
    ModuleInfo(id: 6, title: "Planet Explorer",         subtitle: "Jump across worlds",             icon: "sparkles",                  accentColor: Theme.solarOrange),
]
