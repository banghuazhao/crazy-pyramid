//
//  GameViewController.swift
//  Crazy Pyramid
//
//  Created by Banghua Zhao on 1/15/20.
//  Copyright © 2020 Banghua Zhao. All rights reserved.
//

import SpriteKit
import UIKit

class GameViewController: UIViewController {
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let scene =
            MainMenuScene(size: CGSize(width: 2048, height: 1536))
        let skView = view as! SKView
        #if DEBUG
//            skView.showsFPS = true
//            skView.showsNodeCount = true
        #endif
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
        
        view.addSubview(bannerView)
        bannerView.rootViewController = self
        bannerView.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.centerX.equalToSuperview()
        }
        bannerView.isHidden = true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
