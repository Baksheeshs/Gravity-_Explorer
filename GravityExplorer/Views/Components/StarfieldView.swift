import SwiftUI
import SpriteKit

// MARK: - Starfield Background
struct StarfieldView: View {
    var body: some View {
        SpriteView(scene: StarfieldScene(), options: [.allowsTransparency])
            .ignoresSafeArea()
            .allowsHitTesting(false)
    }
}

class StarfieldScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .clear
        size = view.bounds.size
        scaleMode = .resizeFill
        createStars()
        createShootingStar()
    }

    private func createStars() {
        for _ in 0..<120 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.5...2.0))
            star.fillColor = .white
            star.strokeColor = .clear
            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            star.alpha = CGFloat.random(in: 0.2...0.8)
            star.zPosition = -1

            let twinkle = SKAction.sequence([
                SKAction.fadeAlpha(to: CGFloat.random(in: 0.1...0.4), duration: Double.random(in: 1.0...3.0)),
                SKAction.fadeAlpha(to: CGFloat.random(in: 0.6...1.0), duration: Double.random(in: 1.0...3.0))
            ])
            star.run(SKAction.repeatForever(twinkle))
            addChild(star)
        }
    }

    private func createShootingStar() {
        let action = SKAction.run { [weak self] in
            self?.spawnShootingStar()
        }
        let wait = SKAction.wait(forDuration: 4.0, withRange: 3.0)
        run(SKAction.repeatForever(SKAction.sequence([wait, action])))
    }

    private func spawnShootingStar() {
        let star = SKShapeNode(circleOfRadius: 1.5)
        star.fillColor = .white
        star.strokeColor = .clear
        star.glowWidth = 3

        let startX = CGFloat.random(in: size.width * 0.3...size.width)
        let startY = size.height + 10
        star.position = CGPoint(x: startX, y: startY)
        addChild(star)

        let trail = SKEmitterNode()
        trail.particleBirthRate = 100
        trail.particleLifetime = 0.4
        trail.particleColor = .white
        trail.particleAlpha = 0.6
        trail.particleAlphaSpeed = -1.5
        trail.particleSize = CGSize(width: 1, height: 1)
        trail.particleScaleSpeed = -1
        trail.emissionAngle = .pi * 0.75
        trail.emissionAngleRange = 0.1
        trail.particleSpeed = 10
        trail.targetNode = self
        star.addChild(trail)

        let endX = startX - 200
        let endY = startY - 300
        let move = SKAction.move(to: CGPoint(x: endX, y: endY), duration: 0.6)
        let fade = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        star.run(SKAction.sequence([move, fade, remove]))
    }
}
