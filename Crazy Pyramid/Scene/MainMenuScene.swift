//
//  MainMenuScene.swift
//  Crazy Pyramid
//
//  Created by Banghua Zhao on 1/15/20.
//  Copyright © 2020 Banghua Zhao. All rights reserved.
//

import SnapKit
import SpriteKit
import SwiftyButton
import Then

let tapButtonSound = SKAction.playSoundFileNamed("按键.mp3", waitForCompletion: true)

class MainMenuScene: SKScene {
    // MARK: - didMove

    override func didMove(to view: SKView) {
        bannerView.isHidden = true
        playBackgroundMusic(filename: "选择界面.mp3", repeatForever: true)

        let background = SKSpriteNode(imageNamed: "MainMenu")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(background)

        let easyButton = SKSpriteNode(imageNamed: "easyButton")
        easyButton.position = CGPoint(x: 0, y: 200 - 140)
        easyButton.setScale(0.9)
        easyButton.zPosition = 2
        easyButton.name = "easyButton"
        background.addChild(easyButton)

        let normalButton = SKSpriteNode(imageNamed: "normalButton")
        normalButton.position = CGPoint(x: 0, y: 0 - 140)
        normalButton.setScale(0.9)
        normalButton.zPosition = 2
        normalButton.name = "normalButton"
        background.addChild(normalButton)

        let hardButton = SKSpriteNode(imageNamed: "hardButton")
        hardButton.position = CGPoint(x: 0, y: -200 - 140)
        hardButton.setScale(0.9)
        hardButton.zPosition = 2
        hardButton.name = "hardButton"
        background.addChild(hardButton)
    }

    // MARK: - touchesBegan

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        let nodesAtPoint = nodes(at: touchLocation)
        for node in nodesAtPoint {
            if node.name == "easyButton" {
                backgroundMusicPlayer.stop()
                run(tapButtonSound)
                let myScene = GameScene(size: size, difficutly: .easy)
                myScene.scaleMode = scaleMode
                view?.presentScene(myScene, transition: .doorway(withDuration: 1.5))
            } else if node.name == "normalButton" {
                backgroundMusicPlayer.stop()
                run(tapButtonSound)
                let myScene = GameScene(size: size, difficutly: .normal)
                myScene.scaleMode = scaleMode
                view?.presentScene(myScene, transition: .doorway(withDuration: 1.5))
            } else if node.name == "hardButton" {
                backgroundMusicPlayer.stop()
                run(tapButtonSound)
                let myScene = GameScene(size: size, difficutly: .hard)
                myScene.scaleMode = scaleMode
                view?.presentScene(myScene, transition: .doorway(withDuration: 1.5))
            }
        }
    }
}
