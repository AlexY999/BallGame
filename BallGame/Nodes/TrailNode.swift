import Foundation
import SpriteKit

class TrailNode: SKNode {
    private var trailSegments: [SKShapeNode] = []
    private var maxCount = 15
    private var ballRadius = CGFloat(10)
    private var alphaComponent = CGFloat(0.3)
    
    func addTrailSegment(at position: CGPoint) {
        // Create a trail segment
        let trailSegment = SKShapeNode(rect: CGRect(x: -ballRadius, y: -ballRadius, width: ballRadius * 2, height: ballRadius * 2), cornerRadius: ballRadius)
        trailSegment.fillColor = .white.withAlphaComponent(alphaComponent)
        trailSegment.alpha = 1.0
        trailSegment.position = position
        addChild(trailSegment)
        trailSegments.append(trailSegment)

        // Limit the number of segments to control the length of the trail
        if trailSegments.count > maxCount {
            trailSegments.first?.removeFromParent()
            trailSegments.removeFirst()
        }

        // Apply fading effect to previous segments
        for (index, segment) in trailSegments.enumerated() {
            let alpha = CGFloat(index) / CGFloat(trailSegments.count) * alphaComponent
            segment.alpha = alpha
            segment.position = CGPoint(x: segment.position.x, y: segment.position.y + 2)
        }
    }
}
