//
//  GameOverScene.swift
//  ZombieConga
//
//  Created by Banghua Zhao on 1/15/20.
//  Copyright © 2020 Banghua Zhao. All rights reserved.
//

import Foundation
import GoogleMobileAds
import SpriteKit
import SVProgressHUD
import SwiftyButton

var bannerView: GADBannerView = {
    let bannerView = GADBannerView()
    bannerView.adUnitID = Constants.bannerAdUnitID
    bannerView.load(GADRequest())
    return bannerView
}()

class GameOverScene: SKScene {
    let won: Bool
    var rewardedAd: GADRewardedAd?
    var userDidEarn = false
    var isBack = false
    var interstitial: GADInterstitialAd!

    var previousScene: GameScene!

    init(size: CGSize, won: Bool) {
        self.won = won
        super.init(size: size)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        bannerView.isHidden = false

        var background: SKSpriteNode
        if won {
            playBackgroundMusic(filename: "胜利.mp3", repeatForever: false)

            background = SKSpriteNode(imageNamed: "YouWin")
            background.position =
                CGPoint(x: size.width / 2, y: size.height / 2)

            addChild(background)
            let wait = SKAction.wait(forDuration: 3.0)
            let block = SKAction.run {
                let myScene = MainMenuScene(size: self.size)
                myScene.scaleMode = self.scaleMode
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                self.view?.presentScene(myScene, transition: reveal)
            }
            run(SKAction.sequence([wait, block]))
        } else {
            playBackgroundMusic(filename: "失败.mp3", repeatForever: false)

            background = SKSpriteNode(imageNamed: "YouLose")
            background.position =
                CGPoint(x: size.width / 2, y: size.height / 2)
            addChild(background)

            let menuButton = SKSpriteNode(imageNamed: "menuButton")
            menuButton.position = CGPoint(x: 0, y: -20)
            menuButton.setScale(0.9)
            menuButton.zPosition = 2
            menuButton.name = "menuButton"
            background.addChild(menuButton)

            let continueButton = SKSpriteNode(imageNamed: "continueButton")
            continueButton.position = CGPoint(x: 0, y: -190)
            continueButton.setScale(0.9)
            continueButton.zPosition = 2
            continueButton.name = "continueButton"
            background.addChild(continueButton)
        }
    }
}

// MARK: - action

extension GameOverScene {
    // MARK: - touchesBegan

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        let nodesAtPoint = nodes(at: touchLocation)
        for node in nodesAtPoint {
            if node.name == "menuButton" {
                SVProgressHUD.dismiss()
                isBack = true
                backgroundMusicPlayer.stop()
                run(tapButtonSound)
                let myScene = MainMenuScene(size: size)
                myScene.scaleMode = scaleMode
                let reveal = SKTransition.flipHorizontal(withDuration: 0.6)
                view?.presentScene(myScene, transition: reveal)
            } else if node.name == "continueButton" {
                backgroundMusicPlayer.stop()
                run(tapButtonSound)
                GADInterstitialAd.load(withAdUnitID: Constants.interstitialAdID, request: GADRequest()) { ad, error in
                    if let error = error {
                        print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                        self.continuePrevious(with: 1)
                        return
                    }
                    self.interstitial = ad
                    self.interstitial.fullScreenContentDelegate = self
                    if let ad = self.interstitial, let rootViewController = self.view?.window?.rootViewController {
                        ad.present(fromRootViewController: rootViewController)
                    } else {
                        print("interstitial Ad wasn't ready")
                    }
                }
            }
        }
    }
}

// MARK: - GADFullScreenContentDelegate

extension GameOverScene: GADFullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        continuePrevious(with: 2)
    }
}

// MARK: - private function

extension GameOverScene {
    func continuePrevious(with lives: Int) {
        previousScene.lives = lives
        previousScene.gameOver = false
        previousScene.gameLayer.isPaused = false
        previousScene.isResume = true
        view?.presentScene(previousScene)
    }
}
