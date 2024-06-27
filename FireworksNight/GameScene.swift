//
//  GameScene.swift
//  FireworksNight
//
//  Created by Rodrigo Cavalcanti on 24/06/24.
//

import SpriteKit

class GameScene: SKScene {
    var gameTimer: Timer?
    var fireworks = [SKNode]()
    var scoreLabel: SKLabelNode!
    var explodeButton: SKSpriteNode!
    var instructionLabel: SKLabelNode!

    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var lifePoints = 3
    var hearts: [Heart] = []
    
    var gameOver = false {
        didSet {
            changeGameOver()
        }
    }
    var gameOverNode: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 50, y: 50)
        addChild(scoreLabel)
        
        setupLifePoints()
        
        explodeButton = SKSpriteNode(imageNamed: "buttonReleased")
        explodeButton.setScale(0.5)
        explodeButton.position = CGPoint(x: 910, y: 100)
        explodeButton.name = "buttonOff"
        explodeButton.zPosition = 4
        addChild(explodeButton)
        
        gameOverNode = SKSpriteNode(imageNamed: "gameOver")
        gameOverNode.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        gameOverNode.alpha = 0
        gameOverNode.setScale(1.5)
        gameOverNode.colorBlendFactor = 0.7
        gameOverNode.color = .systemYellow
        addChild(gameOverNode)
        
        instructionLabel = SKLabelNode(fontNamed: "Chalkduster")
        instructionLabel.numberOfLines = 0
        instructionLabel.fontSize = 20
        instructionLabel.text = "Select rockets of the same color,\nclick \"explode\" or shake the\ndevice to score points."
        instructionLabel.zPosition = 0
        instructionLabel.horizontalAlignmentMode = .left
        instructionLabel.verticalAlignmentMode = .top
        instructionLabel.position = CGPoint(x: 50, y: 620)
        instructionLabel.alpha = 0.5
        addChild(instructionLabel)
        
        let logo = SKSpriteNode(imageNamed: "logo")
        logo.position = CGPoint(x: 140, y: 680)
        logo.zPosition = 0
        addChild(logo)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    }
    
    func setupLifePoints() {
        for xPosition in [80, 130, 180] {
            let heart = Heart()
            heart.configure(at: CGPoint(x: xPosition, y: 120))
            heart.zPosition = 0
            addChild(heart)
            hearts.append(heart)
        }
    }
    
    func createFirework(xMovement: CGFloat, x: Int, y: Int) {
        // Create an SKNode that will act as the firework container, and place it at the position that was specified.
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        if Int.random(in: 1...8) == 8 {
            let bomb = SKSpriteNode(imageNamed: "bomb")
            bomb.zPosition = 3
            bomb.setScale(0.4)
            bomb.name = "bomb"
            node.addChild(bomb)
            
            let spin = SKAction.rotate(byAngle: .pi, duration: 0.5) // Rotate 180º for 10 seconds
            let spinForever = SKAction.repeatForever(spin) // Repeat animation forever
            bomb.run(spinForever) // Add action to SKSpriteNode
        } else {
            // Create a rocket sprite node, give it the name "firework" so we know that it's the important thing, adjust its colorBlendFactor property so that we can color it, then add it to the container node.
            let firework = SKSpriteNode(imageNamed: "rocket")
            firework.zPosition = 3
            firework.setScale(0.4)
            firework.colorBlendFactor = 1
            firework.name = "firework"
            node.addChild(firework)
            
            // Give the firework sprite node one of three random colors: cyan, green or red.
            firework.color = [UIColor.yellow, .green, .red].randomElement()!
            
            // Create particles behind the rocket to make it look like the fireworks are lit.
            if let emitter = SKEmitterNode(fileNamed: "fuse") {
                emitter.position = CGPoint(x: 0, y: -40)
                emitter.setScale(1.5)
                emitter.isUserInteractionEnabled = false
                node.addChild(emitter)
            }
        }
        
        // Create a UIBezierPath that will represent the movement of the firework.
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        
        // Tell the container node to follow that path, turning itself as needed.
        let move = SKAction.follow(
            path.cgPath, // Any bezier path.
            asOffset: true, // Whether the path coordinates are absolute or are relative to the node's current position. True means any coordinates in your path are adjusted to take into account the node's position.
            orientToPath: true, // the node will automatically rotate itself as it moves on the path so that it's always facing down the path.
            speed: 200 // how fast it moves along the path.
        )
        node.run(move)
        
        // Add the firework to our fireworks array and also to the scene.
        fireworks.append(node)
        addChild(node)
    }
    
    @objc func launchFireworks() {
        let movementAmount: CGFloat = 1800
        
        switch Int.random(in: 0...3) {
        case 0:
            // fire five, straight up
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge)

        case 1:
            // fire five, in a fan
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)

        case 2:
            // fire five, from the left to the right
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)

        case 3:
            // fire five, from the right to the left
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)

        default:
            break
        }
    }
    
    func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }

        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)

        for case let node as SKSpriteNode in nodesAtPoint {
            
            if node.name == "bomb" {
                explodeBomb()
                break
            }
            
            guard node.name == "firework" else { continue }
            
            for parent in fireworks {
                guard let firework = parent.children.first as? SKSpriteNode else { continue } // Access the first firework sprite node inside the container node.
                
                if firework.name == "selected" && firework.color != node.color { // If any firework node is named as selected but is not the same color as the node the user just touched.
                    firework.name = "firework" // reset name to firework.
                    firework.colorBlendFactor = 1 // reset color blend factor.
                }
            }
            node.name = "selected"
            node.colorBlendFactor = 0
        }
    }
    
    func didHitButton(_ touches: Set<UITouch>) -> Bool {
        guard let touch = touches.first else { return false }

        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        if let button = nodesAtPoint.first(where: {
            $0.name == "buttonOff"
        }) as? SKSpriteNode {
            button.name = "buttonOn"
            button.texture = SKTexture(imageNamed: "buttonPressed")
            explodeFireworks()
            return true
        }
        
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if gameOver {
            restartGame()
            return
        }
        
        if didHitButton(touches) {
            return
        }
        checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if explodeButton.name == "buttonOn" {
            explodeButton.name = "buttonOff"
            explodeButton.texture = SKTexture(imageNamed: "buttonReleased")
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                // this uses a position high above so that rockets can explode off screen.
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    
    func explode(firework: SKNode) {
        if let emitter = SKEmitterNode(fileNamed: "explode") {
            emitter.position = firework.position
            addChild(emitter)
            
            let wait = SKAction.wait(forDuration: 0.7)
            let removeEmitter = SKAction.run { [weak emitter] in
                emitter?.removeFromParent()
            }
            
            emitter.run(SKAction.sequence([wait, removeEmitter]))
        }
        
        firework.removeFromParent()
    }
    
    func explodeFireworks() {
        var numExploded = 0
        
        for (index, fireworkContainer) in fireworks.enumerated().reversed() {
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }
            
            if firework.name == "selected" {
                // destroy this firework!
                explode(firework: fireworkContainer)
                fireworks.remove(at: index)
                numExploded += 1
            }
        }
        
        switch numExploded {
        case 0:
            // nothing - rubbish!
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
        }
    }
    
    func endGame() {
        gameOver = true
        gameTimer?.invalidate()
    }
    
    func changeGameOver() {
        gameOverNode.run(SKAction.fadeAlpha(to: gameOver ? 1 : 0, duration: 0.5))
        instructionLabel.run(SKAction.fadeAlpha(to: gameOver ? 0 : 0.5, duration: 0.5))
        explodeButton.run(SKAction.fadeAlpha(to: gameOver ? 0 : 1, duration: 0.5))
        if gameOver {
            scoreLabel.horizontalAlignmentMode = .center
            scoreLabel.run(SKAction.move(to: CGPoint(x: frame.width / 2, y: (frame.height / 2) - 100), duration: 0.5))
        } else {
            scoreLabel.horizontalAlignmentMode = .left
            scoreLabel.run(SKAction.move(to: CGPoint(x: 50, y: 50), duration: 0.5))
        }
    }
    
    func restartGame() {
        gameOver = false
        score = 0
        lifePoints = 3
        hearts.forEach {
            $0.shrink(reverse: true)
        }
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    }
    
    func explodeBomb() {
        for (index, fireworkContainer) in fireworks.enumerated().reversed() {
            explode(firework: fireworkContainer)
            fireworks.remove(at: index)
        }
        
        if lifePoints > 0 {
            lifePoints -= 1
            if lifePoints >= 0 {
                hearts[lifePoints].shrink()
            }
        } else {
            endGame()
        }
    }
}

#Preview {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "Home")
    let navController = UINavigationController(rootViewController: vc)
    return navController
}
