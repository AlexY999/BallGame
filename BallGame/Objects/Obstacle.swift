import Foundation
import SpriteKit

class Obstacle: SKSpriteNode, SKPhysicsContactDelegate {
    // Add your obstacle-specific properties and methods here

    init() {
        // Initialize your obstacle properties here
        super.init(texture: nil, color: .red, size: CGSize(width: 50, height: 50))
        configurePhysics()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configurePhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.obstacle.rawValue
        physicsBody?.contactTestBitMask = PhysicsCategory.ball.rawValue
        physicsBody?.collisionBitMask = 0
        physicsBody?.usesPreciseCollisionDetection = true
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        physicsBody?.restitution = 0.0
        physicsBody?.linearDamping = 0.0
    }
}
