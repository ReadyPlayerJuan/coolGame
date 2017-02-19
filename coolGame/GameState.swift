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
    static let screenBound = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.fixedCoordinateSpace.bounds.width
    static let screenWidth = UIScreen.main.bounds.width
    
    static var gamescene: GameScene!
    static var editorscene: EditorScene!
    
    //static var drawLayer: CALayer!
    //static var rotateLayer: CALayer!
    static var drawNode: SKShapeNode!
    static var rotateNode: SKShapeNode!
    
    static var playerX = 0.0
    static var playerY = 0.0
    
    static var state = "in menu"
    static var playerState = "free"
    static var inEditor = false
    static var currentlyEditing = false
    
    static var currentDelta = 0.0
    
    static var firstFrame = false
    static var lastFrame = false
    
    static var stageTransitionTimer = 0.0
    static let stageTransitionTimerMax = 5.0
    static var stageTransitionAngle = 0.0
    static var swappedStages = false
    static var exitTarget = 0
    
    static var rotateDirection = "right"
    static var hingeDirection = "right"
    static var rotateTimer = 0.0
    static let rotateTimerMax = 1.0
    
    static var endingStage = false
    static var colorChangeTimer = 0.0
    static let colorChangeTimerMax = 1.0
    
    static var deathTimer = 0.0
    static let deathTimerMax = 4.0
    static var numRotations = 0
    static var prevDirection = 0
    
    static let gravity = 0.6
    static let moveSpeed = 3.3
    
    static var globalRand = 0.0
    
    static var time = 0.0
    
    class func initEntities() {
        EntityManager.entities = []
        
        let p = Player.init()
        EntityManager.addEntity(entity: p)
        
        for row in 0 ... Board.blocks.count-1 {
            for col in 0 ... Board.blocks[0].count-1 {
                EntityManager.addEntity(entity: Board.blocks[row][col]!)
            }
        }
        if(Board.otherEntities.count != 0) {
            for e in Board.otherEntities {
                EntityManager.addEntity(entity: e)
            }
        }
        (EntityManager.getPlayer()! as! Player).reset()
        EntityManager.loadLightSources()
        
        EntityManager.sortEntities()
        EntityManager.redrawEntities(node: drawNode, name: "all")
    }
    
    class func update(delta: TimeInterval) {
        time += delta
        currentDelta = delta
        globalRand = rand()
        
        if(inEditor && currentlyEditing) {
            EditorManager.update(delta: delta)
        }
        
        if(state == "in game") {
            if(playerState == "changing color") {
                firstFrame = false
                lastFrame = false
                
                if(colorChangeTimer == colorChangeTimerMax) {
                    actionFirstFrame()
                }
                
                colorChangeTimer -= delta
                
                if(colorChangeTimer <= 0) {
                    colorChangeTimer = 0
                    actionLastFrame()
                }
            }
            
            if(!currentlyEditing) {
                EntityManager.updateEntities(delta: delta)
                drawNode.position = CGPoint(x: -((EntityManager.getPlayer()!.x + 0.5) * Double(Board.blockSize)), y: ((EntityManager.getPlayer()!.y - 0.5) * Double(Board.blockSize)))
            } else {
                drawNode.position = CGPoint(x: -((EditorManager.camera.x + 0.5) * CGFloat(Board.blockSize)), y: ((EditorManager.camera.y - 0.5) * CGFloat(Board.blockSize)))
            }
        } else if(state == "in menu") {
            //handled by other scenes
        } else if(state == "in editor") {
            
        } else if(state == "stage transition") {
            stageTransitionTimer -= delta
            drawNode.position = CGPoint(x: (-((EntityManager.getPlayer()!.x + 0.5) * Double(Board.blockSize))) + Double(getStageTransitionVector().dx), y: (((EntityManager.getPlayer()!.y - 0.5) * Double(Board.blockSize))) + Double(getStageTransitionVector().dy))
            
            if(!swappedStages && stageTransitionTimer <= stageTransitionTimerMax/2) {
                Board.nextStage()
                initEntities()
                swappedStages = true
                
                if(inEditor) {
                    beginEditorStage()
                }
            }
            
            if(stageTransitionTimer <= 0) {
                stageTransitionTimer = 0
                state = "in game"
                playerState = "free"
                
                drawNode.position = CGPoint(x: -((EntityManager.getPlayer()!.x + 0.5) * Double(Board.blockSize)), y: ((EntityManager.getPlayer()!.y - 0.5) * Double(Board.blockSize)))
            }
            
            EntityManager.updateEntitySprites()
        } else if(state == "rotating") {
            firstFrame = false
            lastFrame = false
            
            if(rotateTimer == rotateTimerMax) {
                actionFirstFrame()
            }
            
            rotateTimer -= delta
            
            if(rotateTimer <= rotateTimerMax / 4 && playerState == "paused" && !currentlyEditing) {
                playerState = "free"
            }
            
            if(rotateTimer <= 0) {
                rotateTimer = 0
                actionLastFrame()
            }
            
            EntityManager.updateEntities(delta: delta)
            if(!currentlyEditing) {
                drawNode.position = CGPoint(x: -((EntityManager.getPlayer()!.x + 0.5) * Double(Board.blockSize)), y: ((EntityManager.getPlayer()!.y - 0.5) * Double(Board.blockSize)))
            } else {
                drawNode.position = CGPoint(x: -((EditorManager.camera.x + 0.5) * CGFloat(Board.blockSize)), y: ((EditorManager.camera.y - 0.5) * CGFloat(Board.blockSize)))
            }
            rotateNode.zRotation = CGFloat(getRotationValue())
        } else if(state == "resetting stage") {
            firstFrame = false
            lastFrame = false
            
            if(deathTimer == deathTimerMax) {
                actionFirstFrame()
            }
            
            deathTimer -= delta
            
            if(deathTimer <= 0) {
                deathTimer = 0
                actionLastFrame()
            }
            
            EntityManager.updateEntities(delta: delta)
            drawNode.position = CGPoint(x: -((EntityManager.getPlayer()!.x + Double(getDeathVector().dx) + 0.5) * Double(Board.blockSize)), y: ((EntityManager.getPlayer()!.y + Double(getDeathVector().dy) - 0.5) * Double(Board.blockSize)))
            rotateNode.zRotation = CGFloat(getDeathRotation())
        }
        
        InputController.prevTouches = InputController.currentTouches
    }
    
    class func gameAction(type: String) {
        if(type == "rotate") {
            state = "rotating"
        } else if(type == "kill player") {
            state = "resetting stage"
        } else if(type == "change color") {
            playerState = "changing color"
            endingStage = false
        } else if(type == "end stage") {
            playerState = "changing color"
            endingStage = true
        }
        
        if(state == "rotating" && playerState != "changing color") {
            playerState = "paused"
            rotateTimer = rotateTimerMax
            rotateDirection = hingeDirection
        } else if(state == "resetting stage") {
            deathTimer = deathTimerMax
            
            GameState.prevDirection = Board.direction
            switch(Board.direction) {
            case 0:
                numRotations = 0; break
            case 1:
                numRotations = 1
                rotateDirection = "left"; break
            case 2:
                numRotations = 2
                rotateDirection = "left"; break
            case 3:
                numRotations = 1
                rotateDirection = "right"; break
            default:
                numRotations = 0; break
            }
        } else if(playerState == "changing color") {
            colorChangeTimer = colorChangeTimerMax
        }
    }
    
    class func actionFirstFrame() {
        firstFrame = true
        
        if(state == "rotating") {
            Board.rotate()
            drawNode.position = CGPoint(x: -((EntityManager.getPlayer()!.x + 0.5) * Double(Board.blockSize)), y: ((EntityManager.getPlayer()!.y - 0.5) * Double(Board.blockSize)))
            GameState.rotateNode.zRotation = CGFloat(GameState.getRotationValue())
            
            if(currentlyEditing) {
                let p = Board.rotatePoint(CGPoint(x: EditorManager.camera.y, y: EditorManager.camera.x), clockwise: rotateDirection == "left")
                EditorManager.camera = CGPoint(x: p.y, y: p.x)
            }
            
            EntityManager.loadLightSources()
        } else if(state == "resetting stage") {
            playerState = "respawning"
            if(numRotations > 0) {
                for _ in 0...numRotations-1 {
                    Board.rotate()
                }
            }
            
            (EntityManager.getPlayer() as! Player).loadDeathEffect(delta: currentDelta)
            
            drawNode.position = CGPoint(x: -((EntityManager.getPlayer()!.x + 0.5) * Double(Board.blockSize)), y: ((EntityManager.getPlayer()!.y - 0.5) * Double(Board.blockSize)))
        } else if(playerState == "changing color") {
            (EntityManager.getPlayer() as! Player).loadColorChangeEffect()
        }
    }
    
    class func actionLastFrame() {
        lastFrame = true
        
        if(state == "rotating") {
            state = "in game"
            rotateNode.zRotation = 0.0
            
            if(inEditor && currentlyEditing) {
                state = "in editor"
            }
        } else if(state == "resetting stage") {
            (EntityManager.getPlayer()! as! Player).reset()
            state = "in game"
            playerState = "free"
            drawNode.position = CGPoint(x: -((EntityManager.getPlayer()!.x + 0.5) * Double(Board.blockSize)), y: ((EntityManager.getPlayer()!.y - 0.5) * Double(Board.blockSize)))
        } else if(playerState == "changing color") {
            if(!endingStage) {
                (EntityManager.getPlayer() as! Player).finishedChangingColor()
                playerState = "free"
            } else {
                (EntityManager.getPlayer() as! Player).finishedChangingColor()
                beginStageTransition()
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
    /*
    class func beginChangingColor() {
        playerState = "changing color"
        colorChangeTimer = colorChangeTimerMax
    }*/
    
    class func beginEditorStage() {
        EditorManager.initElements()
        GameState.currentlyEditing = true
        GameState.inEditor = true
        
        state = "stage transition"
        stageTransitionTimer = 0
        Board.nextStage()
        
        initEntities()
        swappedStages = true
        
        EditorManager.camera = CGPoint(x: Double(Board.blocks[0].count-1)/2.0, y: Double(Board.blocks.count-1)/2.0)
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
    /*
    class func beginRotation() {
        state = "rotating"
        playerState = "paused"
        rotateTimer = rotateTimerMax
        rotateDirection = hingeDirection
        GameState.rotateNode.zRotation = CGFloat(GameState.getRotationValue())
    }
    */
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
    /*
    class func killPlayer() {
        state = "resetting stage"
        playerState = "respawning"
        deathTimer = deathTimerMax
        begunRotation = true
        
        switch(Board.direction) {
        case 0:
            numRotations = 0; break
        case 1:
            numRotations = 1
            rotateDirection = "left"; break
        case 2:
            numRotations = 2
            rotateDirection = "left"; break
        case 3:
            numRotations = 1
            rotateDirection = "right"; break
        default:
            numRotations = 0; break
        }
    }
    */
    class func getDeathVector() -> CGVector {
        var vector = CGVector.init(dx: 0.0, dy: 0.0)
        
        var b = deathTimer / deathTimerMax
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
        
        vector.dx = CGFloat(1-b)*(Board.spawnPoint.x - CGFloat(EntityManager.getPlayer()!.x))
        vector.dy = CGFloat(1-b)*(Board.spawnPoint.y - CGFloat(EntityManager.getPlayer()!.y))
        
        return vector
    }
    
    class func getDeathRotation() -> Double {
        var b = deathTimer / deathTimerMax
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
        
        b *= (Double(numRotations) * 3.14159) / 2
        if(rotateDirection == "left") {
            b *= -1
        }
        return b
    }
    
    private class func rand() -> Double {
        return Double(arc4random())/(pow(2.0, 32.0)-1)
    }
}
