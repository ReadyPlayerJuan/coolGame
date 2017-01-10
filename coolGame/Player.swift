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
    var rotation = 0.0
    var rotationVel = 0.0
    
    var gravitySpeed = 45.0
    var speed = 2.0
    var slide = 0.6
    
    let colAcc = 0.0001
    
    var movingRight = false
    var movingLeft = false
    var jumping = false
    var canHingeLeft = false
    var canHingeRight = false
    
    var colorIndex = -1
    var newColorIndex = -1
    var color: UIColor!
    var newColor: UIColor?
    
    override init() {
        super.init()
        
        collisionType = 0
        collidesWithType = [0, 10, 11, 12, 13, 14, 15]
        collisionPriority = -1
        drawPriority = 99
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
        color = loadColor(colIndex: colorIndex)
        newColor = loadColor(colIndex: newColorIndex)
    }
    
    override func loadSprite() {
        for each in sprite {
            each.removeFromParent()
        }
        let temp = SKShapeNode.init(path: getTrianglePath(corner: CGPoint(x: 0, y: 0), rotation: 0.0, size: Double(Board.blockSize)))
        temp.fillColor = color
        temp.strokeColor = UIColor.clear
        temp.position = CGPoint(x: x * Double(Board.blockSize), y: -y * Double(Board.blockSize))
        
        sprite = [temp]
    }
    
    override func updateSprite() {
        if(GameState.playerState == "free") {
            sprite[0].position = CGPoint(x: x * Double(Board.blockSize), y: -y * Double(Board.blockSize))
            sprite[0].zRotation = 0.0
        } else if(GameState.playerState == "rotating") {
            if(GameState.hingeDirection == "left") {
                let pi = 3.14159265
                var rotationRad = (rotation * 2 * pi) / 360.0
                
                if(GameState.begunRotation) {
                    rotationRad = (30 * 2 * pi) / 360.0
                }
                
                sprite[0].zRotation = CGFloat(rotationRad)
                sprite[0].position = CGPoint(x: x * Double(Board.blockSize), y: -y * Double(Board.blockSize))
            } else {
                let pi = 3.14159265
                var rotationRad = (rotation * 2 * pi) / 360.0
                
                if(GameState.begunRotation) {
                    rotationRad = (-30 * 2 * pi) / 360.0
                }
                
                sprite[0].zRotation = CGFloat(rotationRad)
                sprite[0].position = CGPoint(x: (x + (1 - cos(rotationRad))) * Double(Board.blockSize), y: -(y + sin(rotationRad)) * Double(Board.blockSize))
            }
        } else if(GameState.playerState == "changing color") {
            sprite[0].position = CGPoint(x: x * Double(Board.blockSize), y: -y * Double(Board.blockSize))
            sprite[0].zRotation = 0.0
            
            //draw cool color things later
        }
    }
    
    func loadColor(colIndex: Int) -> UIColor {
        if(colIndex == -1) {
            let blockVariation = rand()*Double(Board.colorVariation)
            
            let c = UIColor(red: 1.0-(CGFloat(blockVariation)/255.0), green: 1.0-(CGFloat(blockVariation)/255.0), blue: 1.0-(CGFloat(blockVariation)/255.0), alpha: 1.0)
            return c
        } else {
            let blockVariation = (Board.colorVariation/2.0) - (rand()*Board.colorVariation)
            var colorArray = ColorTheme.colors[Board.colorTheme][colIndex]
            
            for index in 0 ... 2 {
                colorArray[index] = max(min(colorArray[index] + Int(blockVariation), 255), 0)
            }
            
            let c = UIColor(red: CGFloat(colorArray[0]) / 255.0, green: CGFloat(colorArray[1]) / 255.0, blue: CGFloat(colorArray[2]) / 255.0, alpha: 1.0)
            return c
        }
    }
    
    func move(delta: Double) {
        if(jumping) {
            //check if able to jump
            if(y == Double(Int(y)) && yVel == 0) {
                yVel = -0.22
            }
        }
        if(movingLeft) {
            xVel -= GameState.moveSpeed * delta
        }
        if(movingRight) {
            xVel += GameState.moveSpeed * delta
        }
        
        yVel += GameState.gravity * delta
        xVel *= 0.56
        
        super.update(delta: delta)
    }
    
    func rotate(delta: Double) {
        let rotateSpeed = 2.5
        
        if(movingLeft) {
            rotationVel += rotateSpeed * 3 * delta
        }
        if(movingRight) {
            rotationVel -= rotateSpeed * 3 * delta
        }
        
        if(GameState.hingeDirection == "left") {
            rotationVel -= rotateSpeed * delta
        } else {
            rotationVel += rotateSpeed * delta
        }
        
        rotation += rotationVel
        
        if(GameState.hingeDirection == "left") {
            if(rotation >= 30) {
                rotation = 0.0
                rotationVel = 0.0
                //GameState.playerState = "free"
                GameState.beginRotation()
            } else if(rotation < 0) {
                rotation = 0.0
                rotationVel = 0.0
                GameState.playerState = "free"
            }
        } else {
            if(rotation <= -30) {
                rotation = 0.0
                rotationVel = 0.0
                //GameState.playerState = "free"
                GameState.beginRotation()
            } else if(rotation > 0) {
                rotation = 0.0
                rotationVel = 0.0
                GameState.playerState = "free"
            }
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
        }
        
        //updateSprite()
    }
    
    func checkInputForMovement() {
        movingRight = false
        movingLeft = false
        jumping = false
        
        for t in InputController.currentTouches {
            if(t != nil) {
                //jump if touched top half of the screen
                if(t!.y > 0) {
                    jumping = true
                    
                    //move left if touched bottom left
                } else if(t!.x < 0) {
                    movingLeft = true
                    
                    //move right if touched bottom right
                } else {
                    movingRight = true
                }
            }
        }
    }
    
    override func checkForCollision(with: [Entity]) {
        if(GameState.playerState == "free") {
            canHingeLeft = false
            canHingeRight = false
            
            checkNorthSouthCollision(with: with)
            checkEastWestCollision(with: with)
            
                if(x == Double(Int(x)) && y == Double(Int(y)) && xVel == 0 && yVel == 0) {
                    for t in InputController.currentTouches {
                        if(t != nil) {
                            if(t!.y < 0) {
                                if(t!.x < 0 && canHingeLeft) {
                                    GameState.playerState = "rotating"
                                    GameState.hingeDirection = "left"
                                    rotationVel = 0.1
                                    rotation = 0.0
                                } else if(t!.x >= 0 && canHingeRight) {
                                    GameState.playerState = "rotating"
                                    GameState.hingeDirection = "right"
                                    rotationVel = -0.1
                                    rotation = 0.0
                                }
                            }
                        }
                    }
            }
        }
    }
    
    func checkNorthSouthCollision(with: [Entity]) {
        for entity in with {
            
            //following code cotains collision instruction for blocks and moving blocks only, in the y direction
            if(entity.name == "block" || entity.name == "moving block") {
                
                //make sure the player is able to collide with the current block or moving block by the collision rules defined by entity class
                if(entityCollides(this: self, with: entity)) {
                    
                    let colAcc = 0.001
                    
                    if(yVel > 0) {
                        if(rectContainsPoint(rect: CGRect.init(x: entity.nextX, y: entity.nextY-1, width: 1.0, height: 1.0), point: CGPoint(x: x + colAcc, y: nextY)) || rectContainsPoint(rect: CGRect.init(x: entity.nextX, y: entity.nextY-1, width: 1.0, height: 1.0), point: CGPoint(x: x + 1 - colAcc, y: nextY)) )  {
                            
                            nextY = entity.nextY - 1
                            //print(" \(nextY)")
                            yVel = 0
                            //print(" hit ground, with block at \(Int(entity.x)), \(Int(entity.y))  xmod = \(xMod)")
                        }
                    } else if(yVel < 0) {
                        if(rectContainsPoint(rect: CGRect.init(x: entity.nextX, y: entity.nextY-1, width: 1.0, height: 1.0), point: CGPoint(x: (nextX +         0.5), y: (nextY - (sqrt(3.0) / 2.0)) + colAcc))) {
                            
                            nextY = entity.nextY + (sqrt(3.0) / 2.0) + 2*colAcc
                            yVel = 0
                            //print(" hit ceiling, with block at \(Int(entity.x)), \(Int(entity.y))  xmod = \(xMod)")
                        }
                    }
                    //print("  \(nextX) - \(nextY)")
                }
            }
        }
    }
    
    func checkEastWestCollision(with: [Entity]) {
        for entity in with {
            
            //following code cotains collision instruction for blocks and moving blocks only, in the x direction
            if(entity.name == "block" || entity.name == "moving block") {
                
                //make sure the player is able to collide with the current block or moving block by the collision rules defined by entity class
                if(entityCollides(this: self, with: entity)) {
                    var xMod = 0.0
                    var yMod = 0.0
                    
                    let colAcc = 0.001
                    
                    //check for collision in multiple points throughout the edges of the player
                    let step = 50.0
                    for posInEdge in stride(from: 0.0, through: 1.0, by: (1.0 / step)) {
                        xMod = posInEdge/2
                        yMod = posInEdge * (sqrt(3.0) / -2.0)
                        if(rectContainsPoint(rect: CGRect.init(x: entity.nextX, y: entity.nextY-1, width: 1.0, height: 1.0), point: CGPoint(x: (nextX + xMod), y: (nextY + yMod - colAcc))) && entity.nextX + 0.5 < x) {
                            nextX = entity.nextX + 1 - xMod
                            if(posInEdge <= 2.0 / step) {
                                nextX = entity.nextX + 1
                                if(entity.nextX == Double(Int(entity.nextX)) && entity.nextY == Double(Int(entity.nextY))) {
                                    canHingeLeft = true
                                }
                            }
                            xVel = 0
                            //print(" hit edge, with block at \(Int(entity.nextX)), \(Int(entity.nextY))  xmod = \(xMod)")
                        }
                        if(rectContainsPoint(rect: CGRect.init(x: entity.nextX, y: entity.nextY-1, width: 1.0, height: 1.0), point: CGPoint(x: (nextX + 1 - xMod - colAcc), y: (nextY + yMod - colAcc))) && entity.nextX + 0.5 > x) {
                            nextX = entity.nextX - 1 + xMod
                            if(posInEdge <= 2.0 / step) {
                                nextX = entity.nextX - 1
                                if(entity.nextX == Double(Int(entity.nextX)) && entity.nextY == Double(Int(entity.nextY))) {
                                    canHingeRight = true
                                }
                            }
                            xVel = 0
                            //print(" hit edge, with block at \(Int(entity.nextX)), \(Int(entity.nextY))  xmod = \(xMod)")
                        }
                        //print("  \(nextX) - \(nextY)")
                    }
                } else {
                    if(entity.name == "block" && ((entity as! Block).type == 3 || (entity as! Block).type == 4) && Board.direction == (entity as! Block).direction) {
                        let b = entity as! Block
                        if(nextY == Double(Int(nextY)) && y == entity.y && ((x <= entity.x && nextX >= entity.x) || (x >= entity.x && nextX <= entity.x))) {
                            if(b.type == 3 && b.colorIndex2 != colorIndex) {
                                nextX = entity.nextX
                                xVel = 0
                                
                                newColorIndex = b.colorIndex2
                                newColor = loadColor(colIndex: newColorIndex)
                                GameState.beginChangingColor()
                            } else if(b.type == 4) {
                                nextX = entity.nextX
                                xVel = 0
                                
                                newColorIndex = -1
                                newColor = b.color
                                GameState.exitTarget = b.exitTarget!
                                GameState.beginChangingColor()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func finishedChangingColor() {
        color = newColor
        colorIndex = newColorIndex
        newColorIndex = -1
        newColor = loadColor(colIndex: newColorIndex)
        sprite[0].fillColor = color
        
        collidesWithType = [0]
        collidesWithType.append(colorIndex+10)
        
        if(colorIndex == -1) {
            GameState.beginStageTransition()
        }
    }
    /*
    func update(delta: TimeInterval, time: TimeInterval, scene: GameScene) {
        /*
        if(action == "changing color") {
            y = Double(Int(y+0.5))
            x = Double(Int(x+0.5))
            yVel = 0
            xVel = 0
        } else if(action == "rotating") {
            let rotateVelChange = 2.5
            if(rotation > 0) {
                if(movingRight && !movingLeft) {
                    rotateVel += rotateVelChange*3
                } else if(movingLeft && !movingRight) {
                    rotateVel -= rotateVelChange*3
                }
                rotateVel -= rotateVelChange
                rotation += rotateVel*delta
                
                if(rotation > 30) {
                    rotation = 0
                    rotateVel = 0
                    GameState.beginRotation(clockwise: true)
                    scene.rotate(clockwise: true)
                } else if(rotation < 0) {
                    rotation = 0
                    rotateVel = 0
                    action = "free"
                    scene.resetPlayer()
                }
            } else if(rotation < 0) {
                if(movingRight && !movingLeft) {
                    rotateVel += rotateVelChange*3
                } else if(movingLeft && !movingRight) {
                    rotateVel -= rotateVelChange*3
                }
                rotateVel += rotateVelChange
                rotation += rotateVel*delta
                
                if(rotation < -30) {
                    rotation = 0
                    rotateVel = 0
                    GameState.beginRotation(clockwise: false)
                    scene.rotate(clockwise: false)
                } else if(rotation > 0) {
                    rotation = 0
                    rotateVel = 0
                    action = "free"
                    scene.resetPlayer()
                }
            } else if(rotation == 0) {
                action = "free"
                rotateVel = 0
            }
        } else if(action == "free") {
            if(movingRight && !movingLeft) {
                xVel += speed*delta
            } else if(movingLeft && !movingRight) {
                xVel -= speed*delta
            }
            
            if(jumping && onGround()) {
                yVel = -0.32
            }
            
            //if(!onGround()) {
            yVel += 0.02*gravitySpeed*delta
            //}
            
            nxVel = xVel
            var yCollisionFirst = false
            
            
            if(true) {
                let distanceToNextBlock = Double(Int(x+0.5)) - x
                if(abs(distanceToNextBlock) < abs(xVel) && ((xVel > 0 && distanceToNextBlock > 0) || (xVel < 0 && distanceToNextBlock < 0))) {
                    x = Double(Int(x+0.5))
                    
                    nxVel -= distanceToNextBlock
                    yCollisionFirst = true
                }
            }
            
            checkForColorChange()
            checkForEndGate()
            
            //check for collisions
            let step: Double = Double(2*max(Int(xVel), Int(gravitySpeed*delta*yVel))) + 2.0
            for _ in 0 ... Int(step)-1 {
                
                if(yCollisionFirst) {
                    y += gravitySpeed*delta*yVel/step
                    checkYCollision()
                    
                    x += nxVel/step
                    checkXCollision()
                } else {
                    x += nxVel/step
                    checkXCollision()
                    
                    y += gravitySpeed*delta*yVel/step
                    checkYCollision()
                }
                
                checkEdgeCollision()
            }
            
            xVel *= slide
            //yVel *= slide
            
            if(abs(xVel) < 0.0001) {
                xVel = 0
            }
        }*/
    }
    
    private func checkForColorChange() {/*
        let blocks = Board.blocks!
        
        //check if on a color change triangle block
        if(onGround() && (blocks[Int(y+1-colAcc)][Int(x+0.5)]?.colorIndex2 != colorIndex) && (blocks[Int(y+1-colAcc)][Int(x+0.5)]?.colorIndex2 != -1) && abs(x - Double(Int(x))) <= abs(xVel) && blocks[Int(y+1-colAcc)][Int(x+0.5)]?.direction == Board.direction) {
            x = Double(Int(x+0.5))
            xVel = 0.0
            nxVel = 0.0
            
            prevColorIndex = colorIndex
            colorIndex = (blocks[Int(y+1-colAcc)][Int(x+0.5)]?.colorIndex2)!
            
            prevColor = color
            let colorArray = ColorTheme.colors[Board.colorTheme][colorIndex]
            color = UIColor(red: CGFloat(colorArray[0]) / 255.0, green: CGFloat(colorArray[1]) / 255.0, blue: CGFloat(colorArray[2]) / 255.0, alpha: 1.0).cgColor
            
            action = "changing color"
            GameState.beginChangingColor()
        }*/
    }
    
    private func checkForEndGate() {/*
        let blocks = Board.blocks!
        
        //check if on the end change block
        if(onGround() && (blocks[Int(y+1-colAcc)][Int(x+0.5)]?.type == 4) && abs(x - Double(Int(x))) <= abs(xVel) && blocks[Int(y+1-colAcc)][Int(x+0.5)]?.direction == Board.direction) {
            x = Double(Int(x+0.5))
            xVel = 0.0
            nxVel = 0.0
            
            prevColorIndex = colorIndex
            colorIndex = -2
            
            prevColor = color
            color = blocks[Int(y+1-colAcc)][Int(x+0.5)]?.color.cgColor
            
            action = "changing color"
            GameState.beginChangingColor()
        }*/
    }
    
    private func checkXCollision() {/*
        let blocks = Board.blocks!
        
        if(xVel > 0) {
            //check bottom right corner for collisions caused by x-movement
            if(blocks[Int(y+1-colAcc)][Int(x+1-colAcc)]?.isSolid())! {
                x = Double(Int(x+0.5))
                xVel = 0.0
                //nxVel = 0.0
                
                if(onGround()) {
                    rotation = 1;
                    //action = "rotating"
                }
            }
        } else if(xVel < 0) {
            //check bottom left corner for collisions caused by x-movement
            if(blocks[Int(y+1-colAcc)][Int(x+colAcc)]?.isSolid())! {
                x = Double(Int(x+0.5))
                xVel = 0.0
                //nxVel = 0.0
                
                if(onGround()) {
                    rotation = -1;
                    //action = "rotating"
                }
            }
        }*/
    }
    
    private func checkYCollision() {/*
        let blocks = Board.blocks!
        
        if(yVel > 0) {
            //check bottom left and bottom right corners for a floor
            if((blocks[Int(y+1.0)][Int(x+colAcc)]?.isSolid())! || (blocks[Int(y+1.0)][Int(x+1-colAcc)]?.isSolid())!) {
                y = Double(Int(y+0.5))
                yVel = 0
            }
        } else if(yVel < 0) {
            //check top middle corner for collosion
            let height = sqrt(3)/2.0
            if(blocks[Int(y+1.0-height)][Int(x+0.50)]?.isSolid())! {
                y = Double(Int(y+0.5))-(1.0-height)
                yVel = 0
            }
        }*/
    }
    
    private func checkEdgeCollision() {/*
        let blocks = Board.blocks!
        
        //check for collision between left and right edges and corners of blocks
        var pushed = 0
        let accuracy = 100.0
        for w in 0 ... Int(accuracy) {
            let width = Double(w) / (2.0 * accuracy)
            let height = (1.0 - (2 * width)) * (sqrt(3)/2.0)
            
            var hitRightEdge = false
            var hitLeftEdge = false
            
            while(pushed < 10 && !onGround() && (blocks[Int(y+1+colAcc-height)][Int(x+0.5+width-colAcc)]?.isSolid())!) {
                x -= (1 / accuracy)
                hitRightEdge = true
                pushed += 1
            }
            
            if(pushed >= 10) {
                x += Double(pushed)*(1 / accuracy)
            }
            pushed = 0
            
            while(pushed < 10 && !onGround() && (blocks[Int(y+1+colAcc-height)][Int(x+0.5-width+colAcc)]?.isSolid())!) {
                x += (1 / accuracy)
                hitLeftEdge = true
                pushed += 1
            }
            
            if(pushed >= 10) {
                x -= Double(pushed)*(1 / accuracy)
            }
            
            if(hitRightEdge) {
                yVel *= 0.995
                if(abs(x - Double(Int(x+0.5))) < 0.1) {
                    x = Double(Int(x+0.5))
                }
            } else if(hitLeftEdge) {
                yVel *= 0.995
                if(abs(Double(Int(x+0.5)) - x) < 0.1) {
                    x = Double(Int(x+0.5))
                }
            }
        }*/
    }
    
    func onGround() -> Bool {/*
        if(y == Double(Int(y)) && ((Board.blocks[Int(y+1+colAcc)][Int(x+colAcc)]?.isSolid())! || (Board.blocks[Int(y+1+colAcc)][Int(x+1-colAcc)]?.isSolid())!)) {
            return true
        }*/
        return false
    }*/
}
