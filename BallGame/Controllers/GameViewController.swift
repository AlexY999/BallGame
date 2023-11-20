import UIKit
import SpriteKit

class GameViewController: UIViewController, GameSceneDelegate {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var startView: UIStackView!
    
    private var gameScene: GameScene?
    private var goToResultWindowTag = "goToResultWindowTag"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNewScene()
    }
    
    @IBAction func onStartButtonClick(_ sender: Any) {
        gameScene?.isHidden = false
        startView.isHidden = true
        backButton.isHidden = false
        gameScene?.startGame()
    }
    
    @IBAction func onRestartGame() {
        gameScene?.stopGame()
        setupNewScene()
    }
    
    private func setupNewScene() {
        if let skView = view as? SKView {
            gameScene?.removeFromParent()
            let newGameScene = GameScene(size: skView.bounds.size)
            newGameScene.scaleMode = .aspectFill
            newGameScene.isHidden = true
            newGameScene.gameDelegate = self
            gameScene = newGameScene
            
            startView.isHidden = false
            backButton.isHidden = true
            
            skView.ignoresSiblingOrder = true
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            skView.presentScene(newGameScene)
        }
    }
    
    internal func showResult(won: Bool) {
        performSegue(withIdentifier: goToResultWindowTag, sender: won)
    }

    internal override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == goToResultWindowTag,
           let resultViewController = segue.destination as? ResultViewController,
           let won = sender as? Bool {
            resultViewController.isWinner = won
        }
    }
}
