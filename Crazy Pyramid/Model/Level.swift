//
//  Level.swift
//  Crazy Pyramid
//
//  Created by Banghua Zhao on 2/4/20.
//  Copyright © 2020 Banghua Zhao. All rights reserved.
//

import UIKit

enum GameDifficulty {
    case easy
    case normal
    case hard
}

class Level {
    var difficulty: GameDifficulty!

    var lives: Int!
    var goalTreasure: Int!
    var mummyCrossTime: Double!
    var snakeCrossTime: Double!
    var cameraMovePointsPerSec: CGFloat!
    var archaeologistMovePointsPerSec: CGFloat!
    var archaeologistPoisoningMovePointsPerSec: CGFloat!
    var archaeologistRotateRadiansPerSec: CGFloat!
    var archaeologistPoisoningRotateRadiansPerSec: CGFloat!
    var spawnMummyWaitTime: Double!
    var spawnSnakeWaitTime: Double!
    var spawnTreasureWaitTime: Double!
    var spawnScrollWaitTime: Double!
    var spawnBeetleWaitTime: Double!

    init(difficulty: GameDifficulty) {
        self.difficulty = difficulty
        
        if difficulty == .easy {
            lives = 5
            goalTreasure = 25
            mummyCrossTime = 4.5
            snakeCrossTime = 4.0
            cameraMovePointsPerSec = 150.0
            archaeologistMovePointsPerSec = 480
            archaeologistPoisoningMovePointsPerSec = 250
            archaeologistRotateRadiansPerSec = 4.0 * π
            archaeologistPoisoningRotateRadiansPerSec = 2.0 * π
            spawnMummyWaitTime = 2.5
            spawnSnakeWaitTime = 4.0
            spawnTreasureWaitTime = 2.0
            spawnScrollWaitTime = 8.0
            spawnBeetleWaitTime = 4.0
        } else if difficulty == .normal {
            lives = 4
            goalTreasure = 30
            mummyCrossTime = 4.0
            snakeCrossTime = 3.5
            cameraMovePointsPerSec = 160.0
            archaeologistMovePointsPerSec = 480
            archaeologistPoisoningMovePointsPerSec = 250
            archaeologistRotateRadiansPerSec = 4.0 * π
            archaeologistPoisoningRotateRadiansPerSec = 2.0 * π
            spawnMummyWaitTime = 2.0
            spawnSnakeWaitTime = 3.5
            spawnTreasureWaitTime = 2.5
            spawnScrollWaitTime = 10.0
            spawnBeetleWaitTime = 3.5
        } else if difficulty == .hard {
            lives = 3
            goalTreasure = 30
            mummyCrossTime = 3.5
            snakeCrossTime = 3.0
            cameraMovePointsPerSec = 180.0
            archaeologistMovePointsPerSec = 480
            archaeologistPoisoningMovePointsPerSec = 250
            archaeologistRotateRadiansPerSec = 4.0 * π
            archaeologistPoisoningRotateRadiansPerSec = 2.0 * π
            spawnMummyWaitTime = 1.5
            spawnSnakeWaitTime = 3.0
            spawnTreasureWaitTime = 3.0
            spawnScrollWaitTime = 12.0
            spawnBeetleWaitTime = 3.0
        }
    }
}
