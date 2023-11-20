import SpriteKit
import CoreMotion
import WebKit

enum PhysicsCategory: UInt32 {
    case ball = 1
    case platform = 2
    case obstacle = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    private var motionManager: CMMotionManager!
    private var ball: SKShapeNode!
    private var timerLabel: SKLabelNode!
    private var platforms: [SKSpriteNode] = []
    private var obstacles: [SKSpriteNode] = []
    private var gameStarted = false
    private let ballRadius: CGFloat = 10.0
    private var timer: Timer?
    private var elapsedTime: TimeInterval = 0
    private var lastUpdateTime: TimeInterval = 0
    private var trail: TrailNode?

    private let numOfObstacles = 2
    private let numOfPlatforms = 1
    
    var gameDelegate: GameSceneDelegate?

    override func didMove(to view: SKView) {
        setupPhysics()
        setupMotionManager()
        createTimerLabel()

        trail = TrailNode()
        addChild(trail!)
    }

    func startGame() {
        configureBall()
        configurePlatforms()
        configureObstacles()
        startTimer()
        
        lastUpdateTime = CACurrentMediaTime()
        
        gameStarted = true
    }

    func stopGame() {
        gameStarted = false
        motionManager.stopAccelerometerUpdates()
        timer?.invalidate()
        timer = nil
    }
    
    private func gameOver(won: Bool) {
        stopGame()
        print("gameOver won - \(won)")
        gameDelegate?.showResult(won: won)
    }

    private func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0, dy: -1)
        physicsWorld.contactDelegate = self
    }

    private func setupMotionManager() {
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
    }

    private func configureBall() {
        ball = SKShapeNode(circleOfRadius: ballRadius)
        configureNode(ball, color: .blue, position: CGPoint(x: size.width / 2, y: size.height / 2), isDynamic: true, category: .ball, contact: .platform)
        addChild(ball)
    }
    
    private func configureObstacles() {
        guard numOfObstacles >= 1 else { return }
        
        for _ in 1...numOfObstacles {
            configureObstacle(at: CGPoint(x: size.width / 4, y: CGFloat.random(in: 0...size.height)))
        }
    }
    
    private func configurePlatforms() {
        guard numOfPlatforms >= 1 else { return }

        for _ in 1...numOfPlatforms {
            configurePlatform(at: CGPoint(x: size.width / 2, y: 0))
        }
    }

    private func configureObstacle(at position: CGPoint) {
        let obstacle = Obstacle()
        obstacle.position = position
        addChild(obstacle)
        obstacles.append(obstacle)
    }
    
    private func configurePlatform(at position: CGPoint) {
        let platform = SKSpriteNode(color: .white, size: CGSize(width: size.width * 0.7, height: 20))
        configureNode(platform, position: position, isDynamic: false, category: .platform, linearDamping: 0.0)
        addChild(platform)
        platforms.append(platform)
    }

    private func configureNode(_ node: SKNode, color: SKColor = .white, position: CGPoint, isDynamic: Bool, category: PhysicsCategory, contact: PhysicsCategory? = nil, linearDamping: CGFloat? = nil) {
        node.position = position
        if let spriteNode = node as? SKSpriteNode {
            spriteNode.color = color
        }
        node.physicsBody = SKPhysicsBody(rectangleOf: node.frame.size)
        node.physicsBody?.isDynamic = isDynamic
        node.physicsBody?.categoryBitMask = category.rawValue
        node.physicsBody?.contactTestBitMask = contact?.rawValue ?? 0
        node.physicsBody?.linearDamping = linearDamping ?? 0.0
    }

    override func update(_ currentTime: TimeInterval) {
        guard gameStarted else { return }
        updatePlatforms(currentTime: currentTime)
        updateObstacles(currentTime: currentTime)
        updateBallPosition()
        updateTrail()
        
        lastUpdateTime = currentTime
    }

    private func updatePlatforms(currentTime: TimeInterval) {
        for platform in platforms {
            let speed: CGFloat = 5.0
            let timeSinceLastUpdate = currentTime - lastUpdateTime

            let newY = platform.position.y + speed * 100 * CGFloat(timeSinceLastUpdate) * (platform.physicsBody?.affectedByGravity ?? true ? 0.75 : 1.0)
            platform.position.y = newY

            if newY > size.height {
                let randomX = CGFloat.random(in: (platform.size.width / 2)...(size.width - platform.size.width / 2))
                platform.position = CGPoint(x: randomX, y: -platform.size.height / 2)
            }
        }
    }
    
    private func updateObstacles(currentTime: TimeInterval) {
        for obstacle in obstacles {
            let speed: CGFloat = 3.0
            let timeSinceLastUpdate = currentTime - lastUpdateTime
            let newY = obstacle.position.y + speed * 100 * CGFloat(timeSinceLastUpdate) * (obstacle.physicsBody?.affectedByGravity ?? true ? 0.75 : 1.0)
            obstacle.position.y = newY

            if newY > size.height {
                let randomX = CGFloat.random(in: (obstacle.size.width / 2)...(size.width - obstacle.size.width / 2))
                obstacle.position = CGPoint(x: randomX, y: -obstacle.size.height / 2)
            }
        }
    }
    
    private func updateBallPosition() {
        if let accelerometerData = motionManager.accelerometerData {
            let newX = ball.position.x + CGFloat(accelerometerData.acceleration.x * 15)
            let newXClamped = max(min(newX, size.width - ballRadius), ballRadius)
            let minY = size.height / 2
            let maxY = size.height - ballRadius
            let newYClamped = max(min(ball.position.y, maxY), minY)
            ball.position = CGPoint(x: newXClamped, y: ball.position.y)

            if ball.position.y < minY {
                ball.physicsBody?.affectedByGravity = false
                ball.physicsBody?.velocity = .zero
            } else {
                ball.physicsBody?.affectedByGravity = true
            }

            if newYClamped == maxY {
                gameOver(won: false)
                return
            }
        }
    }

    private func updateTrail() {
        guard let ballPosition = ball?.position else { return }
        trail?.addTrailSegment(at: ballPosition)
    }

    private func createTimerLabel() {
        timerLabel = SKLabelNode(fontNamed: "Arial")
        timerLabel.fontSize = 150
        timerLabel.fontColor = SKColor.white.withAlphaComponent(0.3)
        timerLabel.position = CGPoint(x: size.width / 2, y: size.height / 3 * 2 )
        addChild(timerLabel)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        elapsedTime = 30
        updateTimerLabel()
    }

    @objc private func updateTimer() {
        elapsedTime -= 1
        updateTimerLabel()

        if elapsedTime <= 0 {
            gameOver(won: true)
        }
    }

    private func updateTimerLabel() {
        let seconds = Int(elapsedTime) % 60
        timerLabel.text = "\(seconds)"
    }

    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == PhysicsCategory.ball.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.obstacle.rawValue {
            gameOver(won: false)
        } else if contact.bodyA.categoryBitMask == PhysicsCategory.obstacle.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.ball.rawValue {
            gameOver(won: false)
        }
    }

}

protocol GameSceneDelegate: AnyObject {
    func showResult(won: Bool)
}
