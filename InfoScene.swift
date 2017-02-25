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

class InfoScene: SKScene {
    static let screenHeight = UIScreen.main.fixedCoordinateSpace.bounds.width
    static let screenWidth = UIScreen.main.fixedCoordinateSpace.bounds.height
    
    var mainView: SKView!
    var controller: MenuViewController!
    
    var currentTutorial: SKSpriteNode!
    var imageNum = -1
    let numImages = 3
    
    override func didMove(to view: SKView) {
        mainView = view
        backgroundColor = Board.backgroundColor
        
        imageNum = -1
        nextTutorialImage()
    }
    
    func nextTutorialImage() {
        imageNum += 1
        if(imageNum < numImages) {
            mainView.scene?.removeAllChildren()
            let texture = SKTexture.init(image: UIImage.init(named: "tutorial\(imageNum).png")!)
            currentTutorial = SKSpriteNode.init(texture: texture)
            currentTutorial.scale(to: CGSize.init(width: GameState.screenWidth, height: GameState.screenHeight))
            mainView.scene?.addChild(currentTutorial)
        } else {
            controller.goToScene("menu")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nextTutorialImage()
    }
    
    override func update(_ currentTime: TimeInterval) {
    }
}
