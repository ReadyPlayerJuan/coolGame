//
//  GameScene.swift
//  another test game
//
//  Created by Erin Seel on 12/3/16.
//  Copyright © 2016 Nick Seel. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class TestingScene: GameScene {
    override func beginGame() {
        GameState.testing = true
        
        super.beginGame()
    }
}
