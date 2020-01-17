//
//  Constants.swift
//  Crazy Pyramid
//
//  Created by Banghua Zhao on 12/19/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import UIKit

struct Constants {
    static let isIPhone: Bool = UIDevice.current.userInterfaceIdiom == .phone

    static let bannerAdUnitID = Bundle.main.object(forInfoDictionaryKey: "bannerViewAdUnitID") as? String ?? ""
    static let interstitialAdID = Bundle.main.object(forInfoDictionaryKey: "interstitialAdID") as? String ?? ""


    struct UserDefaultsKeys {
        static let OPEN_COUNT = "OPEN_COUNT"
    }

    struct Easy {
        static let lives = 5
        static let goalTreasure = 15
        static let mummyCrossTime = 4.5
        static let snakeCrossTime = 3.5
        static let cameraMovePointsPerSec: CGFloat = 200.0
        static let archaeologistMovePointsPerSec: CGFloat = 480
        static let archaeologistPoisoningMovePointsPerSec: CGFloat = 200
        static let archaeologistRotateRadiansPerSec: CGFloat = 4.0 * π
        static let archaeologistPoisoningRotateRadiansPerSec: CGFloat = 2.0 * π
        static let spawnMummyWaitTime = 2.5
        static let spawnSnakeWaitTime = 4.0
        static let spawnTreasureWaitTime = 2.0
        static let spawnScrollWaitTime = 6.0
        static let spawnBeetleWaitTime = 4.0
    }

    struct Normal {
        static let lives = 4
        static let goalTreasure = 20
        static let mummyCrossTime = 4.0
        static let snakeCrossTime = 3.0
        static let cameraMovePointsPerSec: CGFloat = 220.0
        static let archaeologistMovePointsPerSec: CGFloat = 480
        static let archaeologistPoisoningMovePointsPerSec: CGFloat = 200
        static let archaeologistRotateRadiansPerSec: CGFloat = 4.0 * π
        static let archaeologistPoisoningRotateRadiansPerSec: CGFloat = 2.0 * π
        static let spawnMummyWaitTime = 2.0
        static let spawnSnakeWaitTime = 3.5
        static let spawnTreasureWaitTime = 2.5
        static let spawnScrollWaitTime = 7.0
        static let spawnBeetleWaitTime = 3.5
    }

    struct Hard {
        static let lives = 3
        static let goalTreasure = 25
        static let mummyCrossTime = 3.5
        static let snakeCrossTime = 2.5
        static let cameraMovePointsPerSec: CGFloat = 250.0
        static let archaeologistMovePointsPerSec: CGFloat = 480
        static let archaeologistPoisoningMovePointsPerSec: CGFloat = 200
        static let archaeologistRotateRadiansPerSec: CGFloat = 4.0 * π
        static let archaeologistPoisoningRotateRadiansPerSec: CGFloat = 2.0 * π
        static let spawnMummyWaitTime = 1.5
        static let spawnSnakeWaitTime = 3.5
        static let spawnTreasureWaitTime = 3.0
        static let spawnScrollWaitTime = 8.0
        static let spawnBeetleWaitTime = 3.0
    }
}
