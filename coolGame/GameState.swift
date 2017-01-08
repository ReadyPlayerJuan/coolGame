//
//  GameState.swift
//  Drawing Test
//
//  Created by Erin Seel on 11/26/16.
//  Copyright © 2016 Nick Seel. All rights reserved.
//

import Foundation
import SpriteKit

class GameState {
    static let screenHeight = UIScreen.main.fixedCoordinateSpace.bounds.width
    static let screenWidth = UIScreen.main.fixedCoordinateSpace.bounds.height
    
    static var gamescene: GameScene!
    
    //static var drawLayer: CALayer!
    //static var rotateLayer: CALayer!
    static var drawNode: SKShapeNode!
    static var rotateNode: SKShapeNode!
    
    static var state = "in menu"
    static var playerState = "free"
    
    static var stageTransitionTimer = 0.0
    static let stageTransitionTimerMax = 5.0
    static var stageTransitionAngle = 0.0
    static var swappedStages = false
    
    static var begunRotation = false
    static var rotateDirection = "right"
    static var hingeDirection = "right"
    static var rotateTimer = 0.0
    static let rotateTimerMax = 1.0
    
    static var colorChangeTimer = 0.0
    static let colorChangeTimerMax = 1.0
    
    static let gravity = 0.6
    static let moveSpeed = 3.3
    
    static var time = 0.0
    
    class func initEntities() {
        EntityManager.entities = []
        for row in 0 ... Board.blocks.count-1 {
            for col in 0 ... Board.blocks[0].count-1 {
                EntityManager.addEntity(entity: Board.blocks[row][col]!)
            }
        }
        let p = Player.init()
        EntityManager.addEntity(entity: p)
        (EntityManager.getPlayer()! as! Player).reset()
        
        EntityManager.addEntity(entity: MovingBlock.init(color: -1, dir: 0, xPos: 2, yPos: 2))
        
        EntityManager.redrawEntities(node: drawNode, name: "all")
    }
    
    class func update(delta: TimeInterval) {
        time += delta
        
        if(state == "in game") {
            drawNode.position = CGPoint(x: -((EntityManager.getPlayer()!.x + 0.5) * Double(Board.blockSize)), y: ((EntityManager.getPlayer()!.y - 0.5) * Double(Board.blockSize)))
            EntityManager.updateEntities(delta: delta)
            
            rotateNode.zRotation = 0.0
            
            if(playerState == "changing color") {
                colorChangeTimer -= delta
                if(colorChangeTimer <= 0) {
                    rotateTimer = 0
                    (EntityManager.getPlayer() as! Player).finishedChangingColor()
                    playerState = "free"
                }
            }
        } else if(state == "in menu") {
        
        } else if(state == "stage transition") {
            stageTransitionTimer -= delta
            drawNode.position = CGPoint(x: (-((EntityManager.getPlayer()!.x + 0.5) * Double(Board.blockSize))) + Double(getStageTransitionVector().dx), y: (((EntityManager.getPlayer()!.y - 0.5) * Double(Board.blockSize))) + Double(getStageTransitionVector().dy))
            
            if(!swappedStages && stageTransitionTimer <= stageTransitionTimerMax/2) {
                Board.nextStage()
                initEntities()
                swappedStages = true
            }
            
            if(stageTransitionTimer <= 0) {
                state = "in game"
                playerState = "free"
                
                drawNode.position = CGPoint(x: -((EntityManager.getPlayer()!.x + 0.5) * Double(Board.blockSize)), y: ((EntityManager.getPlayer()!.y - 0.5) * Double(Board.blockSize)))
            }
        } else if(state == "rotating") {
            rotateTimer -= delta
            
            drawNode.position = CGPoint(x: -((EntityManager.getPlayer()!.x + 0.5) * Double(Board.blockSize)), y: ((EntityManager.getPlayer()!.y - 0.5) * Double(Board.blockSize)))
            EntityManager.updateEntities(delta: delta)
            rotateNode.zRotation = CGFloat(getRotationValue())
            
            if(begunRotation) {
                (EntityManager.getPlayer() as! Player).updateSprite()
                Board.rotate()
                drawNode.position = CGPoint(x: -((EntityManager.getPlayer()!.x + 0.5) * Double(Board.blockSize)), y: ((EntityManager.getPlayer()!.y - 0.5) * Double(Board.blockSize)))
                begunRotation = false
            }
            
            if(rotateTimer <= rotateTimerMax / 4 && playerState == "paused") {
                playerState = "free"
            }
            
            if(rotateTimer <= 0) {
                rotateTimer = 0
                state = "in game"
            }
        }
    }
    
    class func beginGame() {
        state = "stage transition"
        stageTransitionTimer = stageTransitionTimerMax / 2
        Board.nextStage()
        initEntities()
        swappedStages = true
    }
    
    class func beginChangingColor() {
        playerState = "changing color"
        colorChangeTimer = colorChangeTimerMax
    }
    
    class func beginStageTransition() {
        state = "stage transition"
        playerState = "paused"
        stageTransitionTimer = stageTransitionTimerMax
        swappedStages = false
        stageTransitionAngle = rand()*(2*3.14159)
    }
    
    class func getStageTransitionVector() -> CGVector {
        var vector = CGVector(dx: 0, dy: 0)
        vector.dx += 0
        
        let distance = 1600.0*Double(Board.blockSize)
        
        let n = 2.5
        if(!swappedStages) {
            vector.dx = CGFloat(distance*cos(stageTransitionAngle)*pow(1.0-(stageTransitionTimer/stageTransitionTimerMax), n))
            vector.dy = CGFloat(distance*sin(stageTransitionAngle)*pow(1.0-(stageTransitionTimer/stageTransitionTimerMax), n))
        } else {
            vector.dx = CGFloat(-distance*cos(stageTransitionAngle)*pow(0.0+(stageTransitionTimer/stageTransitionTimerMax), n))
            vector.dy = CGFloat(-distance*sin(stageTransitionAngle)*pow(0.0+(stageTransitionTimer/stageTransitionTimerMax), n))
        }
        
        return vector
    }
    
    class func beginRotation() {
        state = "rotating"
        playerState = "paused"
        rotateTimer = rotateTimerMax
        GameState.rotateNode.zRotation = CGFloat(GameState.getRotationValue())
        begunRotation = true
        rotateDirection = hingeDirection
    }
    
    class func getRotationValue() -> Double {
        var b = rotateTimer / rotateTimerMax
        let bottomHalf = b < 0.5
        b -= 0.5
        b = abs(b)
        b *= 2
        b = 1.0-b
        b = pow(b, 4)
        b = 1.0-b
        b /= 2
        if(bottomHalf) {
            b *= -1
        }
        b += 0.5
        
        b *= 3.14159 / 2
        if(rotateDirection == "left") {
            b *= -1
        }
        return b
    }
    
    private class func rand() -> Double {
        return Double(arc4random())/(pow(2.0, 32.0)-1)
    }
}
