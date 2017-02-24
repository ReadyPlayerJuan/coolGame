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

class GameScene: SKScene {
    //var drawLayer: CALayer!
    //var rotateLayer: CALayer!
    var drawNode: SKShapeNode!
    var rotateNode: SKShapeNode!
    
    static let screenHeight = UIScreen.main.fixedCoordinateSpace.bounds.width
    static let screenWidth = UIScreen.main.fixedCoordinateSpace.bounds.height
    
    var delta = 0.0
    
    var mainView: SKView!
    var prevTime = 0.0
    
    override func didMove(to view: SKView) {
        mainView = view
        beginGame()
        
        //UIPasteboard.general.string = "Hello world"
    }
    
    func beginGame() {
        backgroundColor = Board.backgroundColor
        
        //configure main layer
        /*
        rotateLayer = CALayer()
        drawLayer = CALayer()
        
        rotateLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        rotateLayer.position = CGPoint(x: GameScene.screenWidth/2.0, y: GameScene.screenHeight/2.0)
        rotateLayer.bounds = CGRect(x: 0.0, y: 0.0, width: GameScene.screenWidth, height: GameScene.screenHeight)
        mainView.layer.addSublayer(rotateLayer)
        
        rotateLayer.addSublayer(drawLayer)
        
        GameState.gamescene = self
        GameState.drawLayer = drawLayer
        GameState.rotateLayer = rotateLayer*/
        
        GameState.gamescene = self
        
        drawNode = SKShapeNode.init(rect: CGRect(x: 0, y: 0, width: 1, height: 1))
        drawNode.strokeColor = UIColor.clear
        drawNode.fillColor = UIColor.clear
        rotateNode = SKShapeNode.init(rect: CGRect(x: 0, y: 0, width: 1, height: 1))
        rotateNode.strokeColor = UIColor.clear
        rotateNode.fillColor = UIColor.clear
        
        addChild(rotateNode)
        rotateNode.addChild(drawNode)
        
        GameState.drawNode = drawNode
        GameState.rotateNode = rotateNode
        
        GameState.ignoreDelta = true
        GameState.beginGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        InputController.touchesBegan(touches, node: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        InputController.touchesMoved(touches, node: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        InputController.touchesEnded(touches, node: self)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        InputController.touchesCancelled(touches, node: self)
    }
    
    override func update(_ currentTime: TimeInterval) {
        GameState.update(delta: currentTime - prevTime)
        prevTime = currentTime
    }
}
