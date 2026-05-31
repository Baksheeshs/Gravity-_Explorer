# 🌌 Gravity Explorer

**An interactive iOS educational app that teaches gravity through hands-on experiments, 3D simulations, and AI-powered learning.**

[![Swift](https://img.shields.io/badge/Swift-6.0-orange)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2018.0+-blue)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

## Features

### 📚 6 Interactive Modules
1. **What is Gravity?** — Drop objects on a 3D Earth and adjust gravity strength
2. **Capital G vs Small g** — Explore the universal constant vs local acceleration
3. **Acceleration** — Free-fall experiments with velocity-time graphs
4. **Zero Gravity** — Experience weightlessness in orbit
5. **Gravity & Body** — Understand forces on the human body
6. **Planet Explorer** — Compare jump heights across 8 planets

### 🪐 3D Solar System Sandbox
- Real-time N-body gravity simulation using Velocity-Verlet integration
- 8 planets with procedurally generated textures
- Collision detection with particle explosions and momentum conservation
- Adjustable mass, distance, radius, and simulation speed
- Saturn's rings, orbital trails, and HDR bloom effects

### 🤖 Gravity AI Assistant
- Powered by Apple Intelligence (Foundation Models)
- Specialized gravity and space physics educator
- Full chat interface with markdown rendering

### 🎯 Quiz System
- 30 multiple-choice questions (5 per module)
- Module-specific or comprehensive quiz modes
- Detailed explanations for every answer

### 🎵 Synthesized Audio
- Ambient space drone (procedural sine wave synthesis)
- Collision and merge sound effects — no audio files needed

### 📳 Haptic Feedback
- Custom haptic patterns for every interaction type

## Tech Stack

| Framework | Purpose |
|-----------|---------|
| SwiftUI | UI, navigation, animations |
| SceneKit | 3D physics simulations |
| SpriteKit | Starfield backgrounds |
| AVFoundation | Procedural audio synthesis |
| CoreMotion | Device motion data |
| FoundationModels | Apple Intelligence AI |

## Requirements

- iOS 18.0+
- Xcode 16+
- Swift 6.0
- iPad or iPhone

## Architecture

```
GravityExplorer/
├── Models/          # Data models (AI engine, quiz questions)
├── ViewModels/      # MVVM view models (AI chat, quiz state)
├── Views/           # SwiftUI views organized by feature
│   ├── AI/          # AI chat interface
│   ├── Components/  # Reusable components
│   ├── Quiz/        # Quiz flow views
│   └── Module1-6/   # Educational module views
└── Shared/          # Theme, managers, constants
```

## Getting Started

1. Clone the repository
2. Open `Package.swift` in Xcode or Swift Playgrounds
3. Build and run on an iOS 18+ simulator or device

## License

MIT License — see [LICENSE](LICENSE) for details.
