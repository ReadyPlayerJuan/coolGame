//
//  PlayerMovement.swift
//  coolGame
//
//  Created by Nick Seel on 1/14/17.
//  Copyright © 2017 Nick Seel. All rights reserved.
//

import Foundation
import SpriteKit

extension Player {
    func move(delta: Double) {
        /*
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
        */
        
        if((movingLeft && !movingRight) || (movingLeft && movingRight && horizontalMovementTimer < 0)) {
            horizontalMovementTimer -= delta * GameState.accelerationBonus
            if(horizontalMovementTimer < -GameState.slideLength) {
                horizontalMovementTimer = -GameState.slideLength
            }
        } else if((movingRight && !movingLeft) || (movingLeft && movingRight && horizontalMovementTimer > 0)) {
            horizontalMovementTimer += delta * GameState.accelerationBonus
            if(horizontalMovementTimer > GameState.slideLength) {
                horizontalMovementTimer = GameState.slideLength
            }
        } else {
            if(horizontalMovementTimer < 0) {
                horizontalMovementTimer += delta
                if(horizontalMovementTimer > 0) {
                    horizontalMovementTimer = 0
                }
            } else if(horizontalMovementTimer > 0) {
                horizontalMovementTimer -= delta
                if(horizontalMovementTimer < 0) {
                    horizontalMovementTimer = 0
                }
            }
        }
        xVel = GameState.maxMoveSpeed * ((horizontalMovementTimer) / GameState.slideLength) * delta
        
        if(jumping) {
            if(y == Double(Int(y)) && verticalMovementTimer == 0) {
                verticalMovementTimer = -GameState.jumpLength
            }
        }
        let prevHeight = heightAt(time: verticalMovementTimer)
        verticalMovementTimer += delta
        if(verticalMovementTimer > 0 && verticalMovementTimer-delta < 0 && prevYVel < 0) {
            verticalMovementTimer = 0
        }
        let nextHeight = heightAt(time: verticalMovementTimer)
        yVel = nextHeight - prevHeight
        
        prevXVel = xVel
        prevYVel = yVel
        //xVel *= 0.56
        
        super.update(delta: delta)
    }
    
    private func heightAt(time: Double) -> Double {
        return (GameState.gravity * (time * time)) + GameState.jumpHeight
    }
    
    func rotate(delta: Double) {
        yVel = 0
        verticalMovementTimer = 0
        nextY = Double(Int(nextY + 0.5))
        
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
                GameState.gameAction(type: "rotate")
            } else if(rotation < 0) {
                rotation = 0.0
                rotationVel = 0.0
                GameState.playerState = "free"
            }
        } else {
            if(rotation <= -30) {
                rotation = 0.0
                rotationVel = 0.0
                GameState.gameAction(type: "rotate")
            } else if(rotation > 0) {
                rotation = 0.0
                rotationVel = 0.0
                GameState.playerState = "free"
            }
        }
    }
    
    func checkInputForMovement() {
        movingRight = false
        movingLeft = false
        jumping = false
        
        for t in InputController.currentTouches {
            //jump if touched top half of the screen
            if(t.y > 0) {
                jumping = true
                
                //move left if touched bottom left
            } else if(t.x < 0) {
                movingLeft = true
                
                //move right if touched bottom right
            } else {
                movingRight = true
            }
        }
    }
    
    func collide(with: [Entity]) {
        if(GameState.playerState == "free") {
            canHingeLeft = false
            canHingeRight = false
            hitCeiling = false
            
            checkNorthSouthCollision(with: with)
            checkEastWestCollision(with: with)
            
            if(GameState.playerState == "free") {
                if(x == Double(Int(x)) && y == Double(Int(y)) && xVel == 0 && yVel == 0) {
                    for t in InputController.currentTouches {
                        if(t.y < 0) {
                            if(t.x < 0 && canHingeLeft) {
                                GameState.playerState = "rotating"
                                GameState.hingeDirection = "left"
                                rotationVel = 0.1
                                rotation = 0.0
                            } else if(t.x >= 0 && canHingeRight) {
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
                if(Entity.collides(this: self, with: entity)) {
                    
                    let colAcc = 0.001
                    
                    if(yVel > 0) {
                        if(rectContainsPoint(rect: CGRect.init(x: entity.nextX, y: entity.nextY-1, width: 1.0, height: 1.0), point: CGPoint(x: x + colAcc, y: nextY)) || rectContainsPoint(rect: CGRect.init(x: entity.nextX, y: entity.nextY-1, width: 1.0, height: 1.0), point: CGPoint(x: x + 1 - colAcc, y: nextY)) )  {
                            
                            nextY = entity.nextY - 1
                            yVel = 0
                            verticalMovementTimer = 0
                            
                            if(entity.isDangerous) {
                                GameState.gameAction(type: "kill player")
                            }
                            //print(" hit ground, with block at \(Int(entity.x)), \(Int(entity.y))")
                        }
                    } else if(yVel < 0) {
                        if(rectContainsPoint(rect: CGRect.init(x: entity.nextX, y: entity.nextY-1, width: 1.0, height: 1.0), point: CGPoint(x: (nextX +         0.5), y: (nextY - (sqrt(3.0) / 2.0)) + colAcc))) {
                            
                            nextY = entity.nextY + (sqrt(3.0) / 2.0) + 2*colAcc
                            yVel = 0
                            verticalMovementTimer = 0
                            
                            if(entity.isDangerous) {
                                GameState.gameAction(type: "kill player")
                            }
                            //print(" hit ceiling, with block at \(Int(entity.x)), \(Int(entity.y))  xmod = \(xMod)")
                        }
                    } else if(yVel == 0 && entity.isDangerous) {
                        if(rectContainsPoint(rect: CGRect.init(x: entity.nextX, y: entity.nextY-1+colAcc, width: 1.0, height: 1.0), point: CGPoint(x: x + 1 - colAcc, y: nextY+colAcc))) {
                            GameState.gameAction(type: "kill player")
                        }
                    }
                }
            }
        }
    }
    
    func checkEastWestCollision(with: [Entity]) {
        for entity in with {
            
            //following code cotains collision instruction for blocks and moving blocks only, in the x direction
            if(entity.name == "block" || entity.name == "moving block") {
                
                //make sure the player is able to collide with the current block or moving block by the collision rules defined by entity class
                if(Entity.collides(this: self, with: entity)) {
                    var xMod = 0.0
                    var yMod = 0.0
                    
                    let colAcc = 0.001
                    
                    //check for collision in multiple points throughout the edges of the player
                    let step = 50.0
                    
                    for posInEdge in stride(from: 0.0, through: 1.0, by: (1.0 / step)) {
                        xMod = posInEdge/2
                        yMod = posInEdge * (sqrt(3.0) / -2.0)
                        if(rectContainsPoint(rect: CGRect.init(x: entity.nextX, y: entity.nextY-1, width: 1.0, height: 1.0), point: CGPoint(x: (nextX + xMod + colAcc), y: (nextY + yMod - colAcc))) && entity.nextX + 0.5 - colAcc < x) {
                            
                            if(entity.isDangerous) {
                                GameState.gameAction(type: "kill player")
                            } else {
                                nextX = entity.nextX + 1 - xMod
                                if(posInEdge <= 2.0 / step) {
                                    nextX = entity.nextX + 1
                                    if(entity.nextX == Double(Int(entity.nextX)) && entity.nextY == Double(Int(entity.nextY))) {
                                        canHingeLeft = true
                                    }
                                }
                            }
                            xVel = 0
                            //print(" hit edge, with block at \(Int(entity.nextX)), \(Int(entity.nextY))  xmod = \(xMod)")
                        }
                        if(rectContainsPoint(rect: CGRect.init(x: entity.nextX, y: entity.nextY-1, width: 1.0, height: 1.0), point: CGPoint(x: (nextX + 1 - xMod - colAcc), y: (nextY + yMod - colAcc))) && entity.nextX + 0.5 > x) {
                            
                            if(entity.isDangerous) {
                                GameState.gameAction(type: "kill player")
                            } else {
                                nextX = entity.nextX - 1 + xMod
                                if(posInEdge <= 2.0 / step) {
                                    nextX = entity.nextX - 1
                                    if(entity.nextX == Double(Int(entity.nextX)) && entity.nextY == Double(Int(entity.nextY))) {
                                        canHingeRight = true
                                    }
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
                        if(nextY == Double(Int(nextY)) && y == entity.y && ((x <= entity.x && nextX >= entity.x) || (x >= entity.x && nextX <= entity.x)) && Entity.collides(this: self, with: Board.blocks[Int(y+1)][Int(nextX+0.5)]!)) {
                            if(b.type == 3 && b.colorIndex2 != colorIndex) {
                                nextX = entity.nextX
                                xVel = 0
                                
                                newColorIndex = b.colorIndex2
                                newColor = loadColor(colIndex: newColorIndex)
                                GameState.gameAction(type: "change color")
                            } else if(b.type == 4) {
                                nextX = entity.nextX
                                xVel = 0
                                
                                newColorIndex = -1
                                newColor = b.color
                                GameState.exitTarget = b.exitTarget!
                                GameState.gameAction(type: "end stage")
                            }
                        }
                    }
                }
            }
        }
    }
}
