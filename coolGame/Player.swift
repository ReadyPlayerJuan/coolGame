//
//  Player.swift
//  Drawing Test
//
//  Created by Erin Seel on 11/25/16.
//  Copyright © 2016 Nick Seel. All rights reserved.
//

import Foundation
import GameplayKit

class Player: Entity {
    var movementTotal = 0.0
    
    var rotation = 0.0
    var rotationVel = 0.0
    
    var speed = 2.0
    var slide = 0.6
    var verticalMovementTimer = 0.0
    var horizontalMovementTimer = 0.0
    
    let colAcc = 0.0001
    
    var movingRight = false
    var movingLeft = false
    var jumping = false
    var canHingeLeft = false
    var canHingeRight = false
    var hitCeiling = false
    
    var colorIndex = -1
    var newColorIndex = -1
    var color: UIColor!
    var newColor: UIColor?
    
    var respawnEffect: SKShapeNode!
    var deathParticles: [SKShapeNode] = []
    var deathParticleInfo: [[Double]] = [[]]
    var deathParticleColor: UIColor = UIColor.clear
    var prevXVel: Double = 0.0
    var prevYVel: Double = 0.0
    
    override init() {
        super.init()
        
        collisionType = 0
        collidesWithType = [0, 10, 11, 12, 13, 14, 15]
        collisionPriority = -1
        zPos = 99
        controllable = true
        isDynamic = true
        name = "player"
        
        reset()
        
        loadSprite()
    }
    
    func reset() {
        x = Double(Board.spawnPoint.x)
        y = Double(Board.spawnPoint.y)
        xVel = 0.0
        //nxVel = 0.0
        yVel = 0.0
        
        colorIndex = -1
        collidesWithType = [0, 10, 11, 12, 13, 14, 15]
        color = loadColor(colIndex: colorIndex)
        newColor = loadColor(colIndex: newColorIndex)
        
        if(GameState.time > 0.5 && !GameState.inEditor && !(GameState.state == "stage transition")) {
            sprite[0].removeFromParent()
            loadSprite()
            EntityManager.redrawEntities(node: GameState.drawNode, name: "player")
        } else {
            loadSprite()
        }
    }
    
    override func update(delta: TimeInterval) {
        if(GameState.state == "in game") {
            checkInputForMovement()
            
            if(GameState.playerState == "free") {
                move(delta: delta)
            } else if(GameState.playerState == "rotating") {
                rotate(delta: delta)
            } else if(GameState.playerState == "changing color") {
                
            }
        } else if(GameState.state == "rotating") {
            if(GameState.playerState == "free") {
                checkInputForMovement()
                
                move(delta: delta)
            } else if(GameState.playerState == "rotating") {
                rotate(delta: delta)
            }
        } else if(GameState.state == "stage transition") {
            if(GameState.stageTransitionTimer > GameState.stageTransitionTimerMax/2) {
                //sprite[0].alpha = 0
            }
        } else if(GameState.playerState == "respawning") {
            updateDeathEffect()
        }
        
        //updateSprite()
    }
    
    override func loadSprite() {
        if(GameState.currentlyEditing) {
            let path1 = UIBezierPath.init()
            let size = 0.05
            path1.move(to: CGPoint(x: 0, y: Double(Board.blockSize)*size))
            path1.addLine(to: CGPoint(x: Double(Board.blockSize)*size, y: 0))
            path1.addLine(to: CGPoint(x: Double(Board.blockSize)*(1), y: Double(Board.blockSize)*(1-size)))
            path1.addLine(to: CGPoint(x: Double(Board.blockSize)*(1-size), y: Double(Board.blockSize)*(1)))
            
            let line1 = SKShapeNode.init(path: path1.cgPath)
            line1.fillColor = UIColor.red
            line1.strokeColor = UIColor.clear
            line1.zPosition = zPos
            
            let path2 = UIBezierPath.init()
            path2.move(to: CGPoint(x: Double(Board.blockSize), y: Double(Board.blockSize)*size))
            path2.addLine(to: CGPoint(x: Double(Board.blockSize)*(1-size), y: 0))
            path2.addLine(to: CGPoint(x: Double(Board.blockSize)*(0), y: Double(Board.blockSize)*(1-size)))
            path2.addLine(to: CGPoint(x: Double(Board.blockSize)*(size), y: Double(Board.blockSize)*(1)))
            
            let line2 = SKShapeNode.init(path: path2.cgPath)
            line2.fillColor = UIColor.red
            line2.strokeColor = UIColor.clear
            
            line1.position = CGPoint(x: x * Double(Board.blockSize), y: -y * Double(Board.blockSize))
            sprite = [line1]
            line1.addChild(line2)
        } else {
            for each in sprite {
                each.removeFromParent()
            }
            let temp = SKShapeNode.init(path: getTrianglePath(corner: CGPoint(x: 0, y: 0), rotation: 0.0, size: Double(Board.blockSize)))
            temp.fillColor = color
            temp.strokeColor = UIColor.clear
            temp.position = CGPoint(x: x * Double(Board.blockSize), y: -y * Double(Board.blockSize))
            temp.zPosition = zPos
            
            sprite = [temp]
        }
    }
    
    override func updateSprite() {
        if(GameState.currentlyEditing) {
            
        } else if(GameState.playerState == "free") {
            sprite[0].position = CGPoint(x: x * Double(Board.blockSize), y: -y * Double(Board.blockSize))
            
            sprite[0].alpha = 1.0
            sprite[0].zRotation = 0.0
        } else if(GameState.playerState == "rotating") {
            if(GameState.hingeDirection == "left") {
                let pi = 3.14159265
                var rotationRad = (rotation * 2 * pi) / 360.0
                
                if(GameState.firstFrame) {
                    rotationRad = (30 * 2 * pi) / 360.0
                }
                
                sprite[0].zRotation = CGFloat(rotationRad)
                sprite[0].position = CGPoint(x: x * Double(Board.blockSize), y: -y * Double(Board.blockSize))
            } else {
                let pi = 3.14159265
                var rotationRad = (rotation * 2 * pi) / 360.0
                
                if(GameState.firstFrame) {
                    rotationRad = (-30 * 2 * pi) / 360.0
                }
                
                sprite[0].zRotation = CGFloat(rotationRad)
                sprite[0].position = CGPoint(x: (x + (1 - cos(rotationRad))) * Double(Board.blockSize), y: -(y + sin(rotationRad)) * Double(Board.blockSize))
            }
        } else if(GameState.playerState == "changing color") {
            sprite[0].position = CGPoint(x: x * Double(Board.blockSize), y: -y * Double(Board.blockSize))
            sprite[0].zRotation = 0.0
            
            updateColorChangeEffect()
        } else if(GameState.playerState == "respawning") {
            sprite[0].position = CGPoint(x: x * Double(Board.blockSize), y: -y * Double(Board.blockSize))
            sprite[0].fillColor = UIColor.clear
        }
    }
        
    func loadColor(colIndex: Int) -> UIColor {
        if(colIndex == -1) {
            let blockVariation = 0//rand()*Double(Board.colorVariation)
            
            let c = UIColor(red: 1.0-(CGFloat(blockVariation)/255.0), green: 1.0-(CGFloat(blockVariation)/255.0), blue: 1.0-(CGFloat(blockVariation)/255.0), alpha: 1.0)
            return c
        } else {
            let blockVariation = 0//(Board.colorVariation/2.0) - (rand()*Board.colorVariation)
            var colorArray = ColorTheme.colors[Board.colorTheme][colIndex]
            
            for index in 0 ... 2 {
                colorArray[index] = max(min(colorArray[index] + Int(blockVariation), 255), 0)
            }
            
            let c = UIColor(red: CGFloat(colorArray[0]) / 255.0, green: CGFloat(colorArray[1]) / 255.0, blue: CGFloat(colorArray[2]) / 255.0, alpha: 1.0)
            return c
        }
    }
    
    func getColor(colIndex: Int) -> [CGFloat] {
        if(colIndex == -1) {
            let blockVariation = 0//rand()*Double(Board.colorVariation)
            
            let c = [1.0-(CGFloat(blockVariation)/255.0), 1.0-(CGFloat(blockVariation)/255.0), 1.0-(CGFloat(blockVariation)/255.0)]
            return c
        } else {
            let blockVariation = 0//(Board.colorVariation/2.0) - (rand()*Board.colorVariation)
            var colorArray = ColorTheme.colors[Board.colorTheme][colIndex]
            
            for index in 0 ... 2 {
                colorArray[index] = max(min(colorArray[index] + Int(blockVariation), 255), 0)
            }
            
            let c = [CGFloat(colorArray[0]) / 255.0, CGFloat(colorArray[1]) / 255.0, CGFloat(colorArray[2]) / 255.0]
            return c
        }
    }
    
    override func checkForCollision(with: [Entity]) {
        collide(with: with)
    }
    
    override func move() {
        movementTotal += hypot(x - nextX, y - nextY)
        
        GameState.playerX = nextX
        GameState.playerY = nextY
        
        super.move()
    }
}
