//
//  EasyGameScene.swift
//  Crazy Pyramid
//
//  Created by Banghua Zhao on 1/15/20.
//  Copyright © 2020 Banghua Zhao. All rights reserved.
//

import GameplayKit
import Localize_Swift
import SpriteKit
import Then

enum GameState: Int {
    case play, pause
}

class GameScene: SKScene {
    var level: Level!
    var gameLayer = SKNode()

    var gameTime: TimeInterval = 0
    var gameState: GameState = .play

    let archaeologist = SKSpriteNode(imageNamed: "archaeologist1").then { node in
        node.position = CGPoint(x: 600, y: 800)
        node.zPosition = 100
    }

    lazy var archaeologistAnimation: SKAction = {
        var textures: [SKTexture] = []
        for i in 1 ... 4 {
            textures.append(SKTexture(imageNamed: "archaeologist\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        return SKAction.animate(with: textures, timePerFrame: 0.1)
    }()

    lazy var mummyAnimation: SKAction = {
        var textures: [SKTexture] = []
        for i in 1 ... 4 {
            textures.append(SKTexture(imageNamed: "mummy\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        return SKAction.animate(with: textures, timePerFrame: 0.1)
    }()

    lazy var snakeAnimation: SKAction = {
        var textures: [SKTexture] = []
        for i in 1 ... 8 {
            textures.append(SKTexture(imageNamed: "snake\(i)"))
        }
        return SKAction.animate(with: textures, timePerFrame: 0.1)
    }()

    lazy var beetleAnimation: SKAction = {
        var textures: [SKTexture] = []
        for i in 1 ... 5 {
            textures.append(SKTexture(imageNamed: "leafbeetle_\(i)"))
        }
        textures.append(textures[3])
        textures.append(textures[2])
        textures.append(textures[1])
        return SKAction.animate(with: textures, timePerFrame: 0.1)
    }()

    let cameraNode = SKCameraNode()
    var cameraRect: CGRect {
        let x = cameraNode.position.x - size.width / 2
            + (size.width - playableRect.width) / 2
        let y = cameraNode.position.y - size.height / 2
            + (size.height - playableRect.height) / 2
        return CGRect(
            x: x,
            y: y,
            width: playableRect.width,
            height: playableRect.height)
    }

    var cameraMovePointsPerSec: CGFloat = Constants.Easy.cameraMovePointsPerSec

    let livesLabel = SKLabelNode(fontNamed: "Chalkduster").then { node in
        node.text = "\("Lives".localized()): X"
        node.fontColor = SKColor.white
        node.fontSize = 64
        node.zPosition = 150
        node.horizontalAlignmentMode = .left
        node.verticalAlignmentMode = .bottom
    }

    var lives: Int! {
        didSet {
            livesLabel.text = "\("Lives".localized()): \(lives!)"
        }
    }

    var treasures: Int! {
        didSet {
            treasureLabel.text = "\("Treasures".localized()): \(treasures!) / \(level.goalTreasure!)"
        }
    }

    let treasureLabel = SKLabelNode(fontNamed: "Chalkduster").then { node in
        node.text = "\("Treasures".localized()): X"
        node.fontColor = SKColor.white
        node.fontSize = 64
        node.zPosition = 150
        node.horizontalAlignmentMode = .right
        node.verticalAlignmentMode = .bottom
    }

    var playableRect: CGRect!

    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0

    var velocity = CGPoint.zero

    var lastTouchLocation: CGPoint?

    var invincible = false
    var gameOver = false
    var isPoisoning = false
    var isResume = false

    let treasureCollisionSound: SKAction = SKAction.playSoundFileNamed(
        "吃金币.mp3", waitForCompletion: false)
    let mummyCollisionSound: SKAction = SKAction.playSoundFileNamed(
        "碰到木乃伊.mp3", waitForCompletion: false)

    // MARK: - lefe cycle

    init(size: CGSize, difficutly: GameDifficulty) {
        level = Level(difficulty: difficutly)
        super.init(size: size)
        addObservers()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - didMove

    override func didMove(to view: SKView) {
        bannerView.isHidden = true
        gameState = .play
        let playableMargin = sceneCropAmount() / 2.0
        let playableHeight = size.height - 2 * playableMargin

        playableRect = CGRect(x: 0, y: playableMargin,
                              width: size.width,
                              height: playableHeight)

        if level.difficulty != .hard {
            playBackgroundMusic(filename: "背景2.mp3", repeatForever: true)
        } else {
            playBackgroundMusic(filename: "背景1.mp3", repeatForever: true)
        }

        guard !isResume else {
            spawnEveryThing()
            return
        }
        addChild(gameLayer)

        lives = level.lives
        treasures = 0

//        debugDrawPlayableArea()

        for i in 0 ... 1 {
            let background = backgroundNode()
            background.position =
                CGPoint(x: CGFloat(i) * background.size.width, y: 0)
            addChild(background)
        }

        gameLayer.addChild(archaeologist)
        gameLayer.addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)

        livesLabel.position = CGPoint(
            x: -playableRect.size.width / 2 + CGFloat(60),
            y: -playableRect.size.height / 2 + CGFloat(20))
        cameraNode.addChild(livesLabel)

        treasureLabel.position = CGPoint(
            x: playableRect.size.width / 2 - CGFloat(60),
            y: -playableRect.size.height / 2 + CGFloat(20))
        cameraNode.addChild(treasureLabel)

        let pauseButton = SKSpriteNode(imageNamed: "pauseButton")
        pauseButton.position = CGPoint(x: playableRect.size.width / 2 - CGFloat(100), y: playableRect.size.height / 2 - CGFloat(80))
        pauseButton.zPosition = 100
        pauseButton.setScale(0.7)
        pauseButton.name = "pauseButton"
        cameraNode.addChild(pauseButton)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.spawnEveryThing()
        }
    }

    // MARK: - update

    override func update(_ currentTime: TimeInterval) {
        if gameState != .play {
            if !gameLayer.isPaused {
                gameLayer.isPaused = true
                let pauseMenu = SKSpriteNode(imageNamed: "pauseMenu")
                pauseMenu.zPosition = 200
                pauseMenu.position = cameraNode.position
                pauseMenu.name = "pauseMenu"
                addChild(pauseMenu)

                let menuButton = SKSpriteNode(imageNamed: "menuButton")
                menuButton.zPosition = 201
                menuButton.position = CGPoint(x: 0, y: 20)
                menuButton.name = "menuButton"
                pauseMenu.addChild(menuButton)

                let continueButton = SKSpriteNode(imageNamed: "continueButton")
                continueButton.zPosition = 202
                continueButton.position = CGPoint(x: 0, y: -180)
                continueButton.name = "continueButton"
                pauseMenu.addChild(continueButton)
            }
            return
        }

        if isResume {
            lastUpdateTime = currentTime
            isResume = false
        }

        dt = lastUpdateTime > 0 ? currentTime - lastUpdateTime : 0
        gameTime += dt
        lastUpdateTime = currentTime

        move(sprite: archaeologist, velocity: velocity)
        rotate(sprite: archaeologist, direction: velocity)

        if gameTime >= 2.0 {
            moveCamera()
        }

        boundsCheckArchaeologist()

        if lives <= 0 && !gameOver {
            gameOverSetup()
        }

        if treasures >= level.goalTreasure && !gameOver {
            gameOver = true
            print("You win!")
            backgroundMusicPlayer.stop()
            let gameOverScene = GameOverScene(size: size, won: true)
            gameOverScene.scaleMode = scaleMode
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }

    // MARK: - didEvaluateActions

    override func didEvaluateActions() {
        checkCollisions()
    }

    // MARK: - touch

    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)

        let nodesAtPoint = nodes(at: touchLocation)
        for node in nodesAtPoint {
            if node.name == "pauseButton" {
                if !gameLayer.isPaused {
                    gameState = .pause
                    gameLayer.isPaused = true
                    run(tapButtonSound)
                    let pauseMenu = SKSpriteNode(imageNamed: "pauseMenu")
                    pauseMenu.zPosition = 200
                    pauseMenu.position = cameraNode.position
                    pauseMenu.name = "pauseMenu"
                    addChild(pauseMenu)

                    let menuButton = SKSpriteNode(imageNamed: "menuButton")
                    menuButton.zPosition = 201
                    menuButton.position = CGPoint(x: 0, y: 20)
                    menuButton.name = "menuButton"
                    pauseMenu.addChild(menuButton)

                    let continueButton = SKSpriteNode(imageNamed: "continueButton")
                    continueButton.zPosition = 202
                    continueButton.position = CGPoint(x: 0, y: -180)
                    continueButton.name = "continueButton"
                    pauseMenu.addChild(continueButton)
                }
                return
            } else if node.name == "menuButton" && gameLayer.isPaused {
                backgroundMusicPlayer.stop()
                run(tapButtonSound)
                let myScene = MainMenuScene(size: size)
                myScene.scaleMode = scaleMode
                let reveal = SKTransition.flipHorizontal(withDuration: 0.6)
                view?.presentScene(myScene, transition: reveal)
            } else if node.name == "continueButton" && gameLayer.isPaused {
                run(tapButtonSound)
                enumerateChildNodes(withName: "pauseMenu") { node, _ in
                    node.name = ""
                    node.removeFromParent()
                }
                isResume = true
                gameLayer.isPaused = false
                gameState = .play
                return
            }
        }

        sceneTouched(touchLocation: touchLocation)
    }

    override func touchesMoved(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        if !gameLayer.isPaused {
            sceneTouched(touchLocation: touchLocation)
        }
    }

    func sceneTouched(touchLocation: CGPoint) {
        lastTouchLocation = touchLocation
        startArchaeologistAnimation()
        let offset = touchLocation - archaeologist.position
        let direction = offset.normalized()
        if isPoisoning {
            velocity = direction * level.archaeologistPoisoningMovePointsPerSec
        } else {
            velocity = direction * level.archaeologistMovePointsPerSec
        }
    }
}

// MARK: - spawn sprite

extension GameScene {
    func spawnEveryThing() {
        gameLayer.run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run { [weak self] in
                    self?.spawnMummy()
                },
                SKAction.wait(forDuration: level.spawnMummyWaitTime)])), withKey: "spawnMummy")

        gameLayer.run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run { [weak self] in
                    self?.spawnSnake()
                },
                SKAction.wait(forDuration: level.spawnSnakeWaitTime)])), withKey: "spawnSnake")

        gameLayer.run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run { [weak self] in
                    self?.spawnTreasure()
                },
                SKAction.wait(forDuration: level.spawnTreasureWaitTime)])), withKey: "spawnTreasure")

        gameLayer.run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run { [weak self] in
                    self?.spawnScroll()
                },
                SKAction.wait(forDuration: level.spawnScrollWaitTime)])), withKey: "spawnScroll")

        gameLayer.run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run { [weak self] in
                    self?.spawnBeetle()
                },
                SKAction.wait(forDuration: level.spawnBeetleWaitTime)])), withKey: "spawnBeetle")
    }

    func spawnMummy() {
        let mummy = SKSpriteNode(imageNamed: "mummy1")
        mummy.name = "mummy"
        mummy.position = CGPoint(
            x: cameraRect.maxX + mummy.size.width / 2,
            y: CGFloat.random(
                min: cameraRect.minY + mummy.size.height / 2,
                max: cameraRect.maxY - mummy.size.height / 2))
        mummy.zPosition = 54
        gameLayer.addChild(mummy)

        let actionMove =
            SKAction.moveBy(x: -(size.width + mummy.size.width), y: 0, duration: level.mummyCrossTime)
        let actionRemove = SKAction.removeFromParent()
        let group = SKAction.group([
            SKAction.sequence([actionMove, actionRemove]),
            SKAction.repeatForever(mummyAnimation),
        ])
        mummy.run(group)
    }

    func spawnSnake() {
        let snake = SKSpriteNode(imageNamed: "snake1")
        snake.name = "snake"
        snake.position = CGPoint(
            x: cameraRect.maxX + snake.size.width / 2,
            y: CGFloat.random(
                min: cameraRect.minY + snake.size.height / 2,
                max: cameraRect.maxY - snake.size.height / 2))
        snake.zPosition = 53
        gameLayer.addChild(snake)

        let actionMove =
            SKAction.moveBy(x: -(size.width + snake.size.width), y: 0, duration: level.snakeCrossTime)
        let actionRemove = SKAction.removeFromParent()
        let group = SKAction.group([
            SKAction.sequence([actionMove, actionRemove]),
            SKAction.repeatForever(snakeAnimation),
        ])
        snake.run(group)
    }

    func spawnTreasure() {
        // 1
        let treasure = SKSpriteNode(imageNamed: "treasure")
        treasure.name = "treasure"
        treasure.position = CGPoint(
            x: CGFloat.random(min: cameraRect.minX + treasure.size.width + 400,
                              max: cameraRect.maxX - treasure.size.width),
            y: CGFloat.random(min: cameraRect.minY + treasure.size.height,
                              max: cameraRect.maxY - treasure.size.height))
        treasure.zPosition = 50
        treasure.setScale(0)
        gameLayer.addChild(treasure)
        // 2
        let appear = SKAction.scale(to: 1.0, duration: 0.5)
        let scaleUp = SKAction.scale(by: 1.1, duration: 0.25)
        let scaleDown = scaleUp.reversed()
        let fullScale = SKAction.sequence(
            [scaleUp, scaleDown, scaleUp, scaleDown])
        let group = SKAction.group([fullScale])
        let groupWait = SKAction.repeat(group, count: 10)
        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, groupWait, disappear, removeFromParent]
        treasure.run(SKAction.sequence(actions))
    }

    func spawnScroll() {
        // 1
        let scroll = SKSpriteNode(imageNamed: "scroll")
        scroll.name = "scroll"
        scroll.position = CGPoint(
            x: CGFloat.random(min: cameraRect.minX + scroll.size.width + 400,
                              max: cameraRect.maxX - scroll.size.width),
            y: CGFloat.random(min: cameraRect.minY + scroll.size.height,
                              max: cameraRect.maxY - scroll.size.height))
        scroll.zPosition = 50
        scroll.setScale(0)
        gameLayer.addChild(scroll)
        // 2
        let appear = SKAction.scale(to: 1.0, duration: 0.5)
        let wait = SKAction.wait(forDuration: 8.0)
        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, wait, disappear, removeFromParent]
        scroll.run(SKAction.sequence(actions))
    }

    func spawnBeetle() {
        let beetle = SKSpriteNode(imageNamed: "leafbeetle_1")
        beetle.name = "beetle"
        beetle.setScale(0)

        beetle.position = CGPoint(
            x: CGFloat.random(min: cameraRect.minX + beetle.size.width + 400,
                              max: cameraRect.maxX - beetle.size.width + 400),
            y: CGFloat.random(min: cameraRect.minY + beetle.size.height,
                              max: cameraRect.maxY - beetle.size.height))
        beetle.zPosition = 51
        gameLayer.addChild(beetle)

        let appear = SKAction.scale(to: 0.6, duration: 0.5)
        let groupWait = SKAction.wait(forDuration: 10)
        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, groupWait, disappear, removeFromParent]
        let group = SKAction.group([
            SKAction.sequence(actions),
            SKAction.repeatForever(beetleAnimation),
        ])
        beetle.run(group)
    }
}

// MARK: - action

extension GameScene {
    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        sprite.position += amountToMove
    }

    func rotate(sprite: SKSpriteNode, direction: CGPoint) {
        let shortest = shortestAngleBetween(angle1: sprite.zRotation, angle2: velocity.angle)
        var amountToRotate: CGFloat
        if isPoisoning {
            amountToRotate = min(level.archaeologistPoisoningRotateRadiansPerSec * CGFloat(dt), abs(shortest))
        } else {
            amountToRotate = min(level.archaeologistRotateRadiansPerSec * CGFloat(dt), abs(shortest))
        }
        sprite.zRotation += shortest.sign() * amountToRotate
    }

    func archaeologistHit(treasure: SKSpriteNode) {
        treasures += 1
        treasure.name = ""
        treasure.run(
            SKAction.sequence([
                SKAction.group([
                    SKAction.rotate(byAngle: π * 4, duration: 1.0),
                    SKAction.scale(to: 0, duration: 1.0),
                ]),
                SKAction.removeFromParent(),
        ]))
        run(treasureCollisionSound)
    }

    func archaeologistHit(scroll: SKSpriteNode) {
        scroll.name = ""
        scroll.run(
            SKAction.sequence([
                SKAction.group([
                    SKAction.rotate(byAngle: π * 4, duration: 1.0),
                    SKAction.scale(to: 0, duration: 1.0),
                ]),
                SKAction.removeFromParent(),
        ]))

        run(SKAction.repeat(SKAction.run {
            self.spawnTreasure()
        }, count: 5))

        run(treasureCollisionSound)
    }

    func archaeologistHit(mummy: SKSpriteNode) {
        invincible = true
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime).truncatingRemainder(
                dividingBy: slice)
            node.isHidden = remainder > slice / 2
        }
        let setHidden = SKAction.run { [weak self] in
            self?.archaeologist.isHidden = false
            self?.invincible = false
        }
        archaeologist.run(SKAction.sequence([blinkAction, setHidden]))

        run(mummyCollisionSound)

        lives -= 1
    }

    func archaeologistHit(snake: SKSpriteNode) {
        invincible = true
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime).truncatingRemainder(
                dividingBy: slice)
            node.isHidden = remainder > slice / 2
        }
        let setHidden = SKAction.run { [weak self] in
            self?.archaeologist.isHidden = false
            self?.invincible = false
        }
        archaeologist.run(SKAction.sequence([blinkAction, setHidden]))

        run(mummyCollisionSound)

        lives -= 1
    }

    func archaeologistHit(beetle: SKSpriteNode) {
        beetle.name = ""

        beetle.run(
            SKAction.sequence([
                SKAction.group([
                    SKAction.scale(to: 0, duration: 1.0),
                ]),
                SKAction.removeFromParent(),
        ]))
        archaeologist.removeAction(forKey: "hitBeelte")
        archaeologist.run(
            SKAction.sequence([
                SKAction.run {
                    self.isPoisoning = true
                },
                SKAction.colorize(with: SKColor.green, colorBlendFactor: 0.6, duration: 1.0),
                SKAction.wait(forDuration: 3.0),
                SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.5),
                SKAction.run {
                    self.isPoisoning = false
                },
            ]), withKey: "hitBeelte"
        )

        run(mummyCollisionSound)
    }

    func checkCollisions() {
        gameLayer.enumerateChildNodes(withName: "treasure") { node, _ in
            let treasure = node as! SKSpriteNode
            if treasure.frame.intersects(self.archaeologist.frame) {
                self.archaeologistHit(treasure: treasure)
            }
        }

        gameLayer.enumerateChildNodes(withName: "scroll") { node, _ in
            let scroll = node as! SKSpriteNode
            if scroll.frame.intersects(self.archaeologist.frame) {
                self.archaeologistHit(scroll: scroll)
            }
        }

        if invincible {
            return
        }

        var hitMummies: [SKSpriteNode] = []
        gameLayer.enumerateChildNodes(withName: "mummy") { node, _ in
            let mummy = node as! SKSpriteNode
            if mummy.frame.insetBy(dx: 80, dy: 20).intersects(
                self.archaeologist.frame) {
                hitMummies.append(mummy)
            }
        }
        for mummy in hitMummies {
            archaeologistHit(mummy: mummy)
        }

        gameLayer.enumerateChildNodes(withName: "snake") { node, _ in
            let snake = node as! SKSpriteNode
            if snake.frame.insetBy(dx: 80, dy: 20).intersects(
                self.archaeologist.frame) {
                self.archaeologistHit(snake: snake)
            }
        }

        gameLayer.enumerateChildNodes(withName: "beetle") { node, _ in
            let beetle = node as! SKSpriteNode
            if beetle.frame.insetBy(dx: 10, dy: 10).intersects(self.archaeologist.frame) {
                self.archaeologistHit(beetle: beetle)
            }
        }
    }
}

// MARK: - animation

extension GameScene {
    func startArchaeologistAnimation() {
        if archaeologist.action(forKey: "animation") == nil {
            archaeologist.run(
                SKAction.repeatForever(archaeologistAnimation),
                withKey: "animation")
        }
    }

    func stopArchaeologistAnimation() {
        archaeologist.removeAction(forKey: "animation")
    }
}

// MARK: - helper

extension GameScene {
    func backgroundNode() -> SKSpriteNode {
        // 1
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPoint.zero
        backgroundNode.name = "background"
        backgroundNode.zPosition = -1
        backgroundNode.anchorPoint = CGPoint.zero

        // 2
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)

        // 3
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPoint.zero
        background2.position =
            CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)

        // 4
        backgroundNode.size = CGSize(
            width: background1.size.width + background2.size.width,
            height: background1.size.height)
        return backgroundNode
    }

    func debugDrawPlayableArea() {
        let shape = SKShapeNode(rect: playableRect)
        shape.strokeColor = SKColor.red
        shape.lineWidth = 4.0
        addChild(shape)
    }

    func boundsCheckArchaeologist() {
        let bottomLeft = CGPoint(x: cameraRect.minX, y: cameraRect.minY)
        let topRight = CGPoint(x: cameraRect.maxX, y: cameraRect.maxY)

        if archaeologist.position.x <= bottomLeft.x {
            archaeologist.position.x = bottomLeft.x
            velocity.x = abs(velocity.x)
        }
        if archaeologist.position.x >= topRight.x {
            archaeologist.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if archaeologist.position.y <= bottomLeft.y {
            archaeologist.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if archaeologist.position.y >= topRight.y {
            archaeologist.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }

    func moveCamera() {
        let backgroundVelocity =
            CGPoint(x: cameraMovePointsPerSec, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        cameraNode.position += amountToMove

        enumerateChildNodes(withName: "background") { node, _ in
            let background = node as! SKSpriteNode
            if background.position.x + background.size.width <
                self.cameraRect.origin.x {
                background.position = CGPoint(
                    x: background.position.x + background.size.width * 2,
                    y: background.position.y)
            }
        }
    }

    func sceneCropAmount() -> CGFloat {
        guard let view = view else { return 0 }

        let scale = view.bounds.size.width / size.width
        print("scale: \(scale)")
        let scaledHeight = size.height * scale
        let scaledOverlap = scaledHeight - view.bounds.size.height
        print("scaledOverlap: \(scaledOverlap)")
        return scaledOverlap / scale
    }
}

// MARK: - game play

extension GameScene {
    func gameOverSetup() {
        gameOver = true
        print("You lose!")
        backgroundMusicPlayer.stop()
        gameLayer.isPaused = true
        gameLayer.removeAction(forKey: "spawnMummy")
        gameLayer.removeAction(forKey: "spawnSnake")
        gameLayer.removeAction(forKey: "spawnTreasure")
        gameLayer.removeAction(forKey: "spawnScroll")
        gameLayer.removeAction(forKey: "spawnBeetle")
        let gameOverScene = GameOverScene(size: size, won: false)
        gameOverScene.previousScene = self
        gameOverScene.scaleMode = scaleMode
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        view?.presentScene(gameOverScene, transition: reveal)
    }
}

// MARK: - Notifications

extension GameScene {
    func addObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] _ in
            self?.applicationDidBecomeActive()
        }
        notificationCenter.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil) { [weak self] _ in
            self?.applicationWillResignActive()
        }
        notificationCenter.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { [weak self] _ in
            self?.applicationDidEnterBackground()
        }
    }

    func applicationDidBecomeActive() {
        print("* applicationDidBecomeActive")
    }

    func applicationWillResignActive() {
        print("* applicationWillResignActive")
        gameState = .pause
    }

    func applicationDidEnterBackground() {
        print("* applicationDidEnterBackground")
        gameState = .pause
    }
}
