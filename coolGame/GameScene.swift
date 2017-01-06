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
    
    static let screenHeight = UIScreen.main.fixedCoordinateSpace.bounds.width
    static let screenWidth = UIScreen.main.fixedCoordinateSpace.bounds.height
    
    var mainView: SKView!
    var prevTime = 0.0
    var firstFrame = true
    
    override func didMove(to view: SKView) {
        mainView = view
        
        beginGame()
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
        
        addChild(drawNode)
        GameState.drawNode = drawNode
        
        Board.nextStage()
        
        GameState.initEntities()
        
        /*
        GameState.beginStageTransition()
        GameState.swappedStages = true
        GameState.stageTransitionTimer = GameState.stageTransitionTimerMax/4.0
        Board.nextStage()
        Player.reset()
        
        playerLayer.addSublayer(TriangleLayer.init(col: Player.color, corner: CGPoint(x: (GameScene.screenWidth/2)-CGFloat(Board.blockSize/2), y: ((GameScene.screenHeight/2)+CGFloat(Board.blockSize/2))+0.0), rotate: 0.0, sideLength: Double(Board.blockSize)))
        
        Board.drawBlocks(layer: drawLayer, time: 0.0)
        
        //rotate screen to correct orientation based on landscape mode
        if(!UIInterfaceOrientation.landscapeRight.isLandscape) {
            var zRotation: CATransform3D
            zRotation = CATransform3DMakeRotation(CGFloat(3.1415926), 0.0, 0.0, 1.0)
            rotationLayer.transform = zRotation
        }
        
        GameState.beginGame()*/
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
    
    func nextStage() {
        /*
        Board.nextStage()
        Player.reset()
        
        for l in drawLayer.sublayers! {
            l.removeFromSuperlayer()
        }
        
        Board.drawBlocks(layer: drawLayer, time: 0.0)
        resetPlayer()
        */
    }
    
    func resetPlayer() {
        /*
        for sublayer in playerLayer.sublayers! {
            sublayer.removeFromSuperlayer()
        }
        
        CATransaction.setAnimationDuration(0.0)
        playerLayer.addSublayer(TriangleLayer.init(col: Player.color, corner: CGPoint(x: (GameScene.screenWidth/2)-CGFloat(Board.blockSize/2)-0.5, y: ((GameScene.screenHeight/2)+CGFloat(Board.blockSize/2))+0.0), rotate: 0.0, sideLength: Double(Board.blockSize)+1.0))
        CATransaction.setAnimationDuration(0.0)
        playerLayer.position = CGPoint(x:0, y:0)
        playerLayer.opacity = 1.0
        */
    }
    /*
    func rotate(clockwise: Bool) {
        Board.rotate(clockwise: clockwise)
        
        drawLayer.removeFromSuperlayer()
        drawLayer = CALayer()
        rotationLayer.addSublayer(drawLayer)
        Board.drawBlocks(layer: drawLayer, time: prevTime)
        
        CATransaction.setAnimationDuration(0.0)
        playerLayer.removeFromSuperlayer()
        resetPlayer()
        rotationLayer.addSublayer(playerLayer)
        
        Board.endBlockLayer.removeFromSuperlayer()
        Board.endBlockLayer = Board.endBlock.getSpriteLayer(x: Int(Board.endBlockPoint.x), y: Int(Board.endBlockPoint.y), time: prevTime)[1]
        drawLayer.addSublayer(Board.endBlockLayer)
        
        var zRotation: CATransform3D
        zRotation = CATransform3DMakeRotation(CGFloat(GameState.getRotationValue()), 0.0, 0.0, 1.0)
        rotationLayer.transform = zRotation
    }*/
    
    override func update(_ currentTime: TimeInterval) {
        if(firstFrame) {
            firstFrame = false
            prevTime = currentTime
        }
        GameState.update(delta: currentTime - prevTime)
        prevTime = currentTime
        
        /*
        if(GameState.state == "in menu") {
            
        } else {
            var delta = currentTime - prevTime
            prevTime = currentTime
            
            //safety for when the game starts and the difference between currentTime and prevTime is like a billion
            if(delta > 0.5) {
                delta = 0
            }
            GameState.update(delta: delta)
            
            Board.endBlockLayer.removeFromSuperlayer()
            Board.endBlockLayer = Board.endBlock.getSpriteLayer(x: Int(Board.endBlockPoint.x), y: Int(Board.endBlockPoint.y), time: currentTime)[1]
            drawLayer.addSublayer(Board.endBlockLayer)
            
            if(GameState.state == "in game") {
                
                Player.resetMovement()
                for point in InputController.currentTouches {
                    if(point != nil) {
                        if((point?.y)! > 0) {
                            Player.jumping = true
                        } else {
                            if((point?.x)! < 0) {
                                Player.movingLeft = true
                            } else if((point?.x)! >= 0) {
                                Player.movingRight = true
                            }
                        }
                    }
                }
                
                Player.update(delta: delta, time: currentTime, scene: self)
                
                if(Player.action == "rotating") {
                    if(Player.rotation > 0) {
                        playerLayer.replaceSublayer((playerLayer.sublayers?[0])!, with: TriangleLayer.init(col: Player.color, corner: CGPoint(x: (GameScene.screenWidth/2)+CGFloat(Board.blockSize/2 + 0), y: ((GameScene.screenHeight/2)+CGFloat(Board.blockSize/2))+0.0), rotate: (Player.rotation-120) * (3.14159/180.0), sideLength: Double(Board.blockSize)))
                    } else if(Player.rotation < 0) {
                        playerLayer.replaceSublayer((playerLayer.sublayers?[0])!, with: TriangleLayer.init(col: Player.color, corner: CGPoint(x: (GameScene.screenWidth/2)-CGFloat(Board.blockSize/2 + 0), y: ((GameScene.screenHeight/2)+CGFloat(Board.blockSize/2))+0.0), rotate: (Player.rotation) * (3.14159/180.0), sideLength: Double(Board.blockSize)))
                    }
                }
                
                CATransaction.setAnimationDuration(0.0)
                drawLayer.position = CGPoint(
                    x: (GameScene.screenWidth / 2.0) - CGFloat(Double(Board.blockSize)*(Player.x+0.5)),
                    y: (GameScene.screenHeight / 2.0) - CGFloat(Double(Board.blockSize)*(Player.y+0.5)))
            } else if(GameState.state == "rotating") {
                Player.resetMovement()
                
                CATransaction.setAnimationDuration(0.0)
                var zRotation: CATransform3D
                zRotation = CATransform3DMakeRotation(CGFloat(GameState.getRotationValue()), 0.0, 0.0, 1.0)
                rotationLayer.transform = zRotation
            } else if(GameState.state == "changing color") {
                resetPlayer()
                Player.drawColorEffect(layer: playerLayer)
            } else if(GameState.state == "stage transition") {
                CATransaction.setAnimationDuration(0.0)
                drawLayer.position = CGPoint(
                    x: (GameScene.screenWidth / 2.0) - CGFloat(Double(Board.blockSize)*(Player.x+0.5)),// + GameState.getStageTransitionVector().dx,
                    y: (GameScene.screenHeight / 2.0) - CGFloat(Double(Board.blockSize)*(Player.y+0.5)))// + GameState.getStageTransitionVector().dy)
                
                CATransaction.setAnimationDuration(0.0)
                rotationLayer.position = CGPoint(
                    x: (GameScene.screenWidth / 2.0) + GameState.getStageTransitionVector().dx,
                    y: (GameScene.screenHeight / 2.0) + GameState.getStageTransitionVector().dy)
            }
        }*/
    }
}
