//
//  MovingBlock.swift
//  another test game
//
//  Created by Nick Seel on 12/10/16.
//  Copyright © 2016 Nick Seel. All rights reserved.
//

import Foundation
import SpriteKit

class MovingBlock: Entity {
    var direction = 0
    var colorIndex = -1
    var color = UIColor.purple
    
    init(color: Int, dir: Int, xPos: Double, yPos: Double) {
        super.init()
        
        direction = dir
        x = xPos
        y = yPos
        
        name = "moving block"
        isDynamic = true
        collisionPriority = 10
        drawPriority = 10
        colorIndex = color
        
        if(colorIndex == -1) {
            collidesWithType = [0]
            collisionType = 0
        } else {
            collidesWithType = [0, colorIndex + 10]
            collisionType = colorIndex + 10
        }
        
        initColor()
        
        loadSprite()
    }
    
    override func update(delta: TimeInterval) {
        if(GameState.playerState == "free" || GameState.playerState == "rotating") {
            if((Board.direction + direction) % 2 == 0) {
                yVel += GameState.gravity * delta
            }
        } else if(GameState.state == "rotating") {
            if(xVel > 0) {
                xVel += GameState.gravity * delta
            } else if(xVel < 0) {
                xVel -= GameState.gravity * delta
            }
        }
        
        sprite[0].position = CGPoint(x: x * Double(Board.blockSize), y: -y * Double(Board.blockSize))
        
        super.update(delta: delta)
    }
    
    func initColor() {
        //var color = UIColor.purple
        if(colorIndex == -1) {
            let blockVariation = Int(rand()*Board.colorVariation)
            color = UIColor(red: 1.0-(CGFloat(blockVariation)/255.0), green: 1.0-(CGFloat(blockVariation)/255.0), blue: 1.0-(CGFloat(blockVariation)/255.0), alpha: 1.0)
        } else {
            let n = 1.0
            let blockVariation = Int((Board.colorVariation*n) - (rand()*Board.colorVariation*2*n))
            var colorArray = ColorTheme.colors[Board.colorTheme][colorIndex]
            
            for index in 0 ... 2 {
                colorArray[index] = max(min(colorArray[index] + blockVariation, 255), 0)
            }
            
            color = UIColor(red: CGFloat(colorArray[0]) / 255.0, green: CGFloat(colorArray[1]) / 255.0, blue: CGFloat(colorArray[2]) / 255.0, alpha: 1.0)
        }
    }
    
    override func checkForCollision(with: [Entity]) {
        for entity in with {
            if(entityCollides(this: self, with: entity)) {
                if(entity.name == "block") {
                    let colAcc = 0.001
                    
                    if(yVel > 0) {
                        if(rectContainsPoint(rect: CGRect.init(x: entity.nextX, y: entity.nextY-1, width: 1.0, height: 1.0), point: CGPoint(x: x + colAcc, y: nextY)) || rectContainsPoint(rect: CGRect.init(x: entity.nextX, y: entity.nextY-1, width: 1.0, height: 1.0), point: CGPoint(x: x + 1 - colAcc, y: nextY)) )  {
                            
                            nextY = entity.nextY - 1
                            yVel = 0
                        }
                    } else if(xVel < 0) {
                        if(rectContainsPoint(rect: CGRect.init(x: entity.nextX, y: entity.nextY, width: 1.0, height: 1.0), point: CGPoint(x: nextX, y: y + colAcc)) || rectContainsPoint(rect: CGRect.init(x: entity.nextX, y: entity.nextY, width: 1.0, height: 1.0), point: CGPoint(x: nextX, y: y + 1 - colAcc)) )  {
                            
                            nextX = entity.nextX + 1
                            xVel = 0
                        }
                    } else if(xVel > 0) {
                        if(rectContainsPoint(rect: CGRect.init(x: entity.nextX, y: entity.nextY, width: 1.0, height: 1.0), point: CGPoint(x: nextX + 1, y: y + colAcc)) || rectContainsPoint(rect: CGRect.init(x: entity.nextX, y: entity.nextY, width: 1.0, height: 1.0), point: CGPoint(x: nextX + 1, y: y + 1 - colAcc)) )  {
                            
                            nextX = entity.nextX - 1
                            xVel = 0
                        }
                    }
                } else if(entity.name == "moving block") {
                    
                }
            }
        }
    }
    
    override func loadSprite() {
        let s = SKShapeNode.init(rect: CGRect.init(x: 0, y: 0, width: Double(Board.blockSize+0), height: Double(Board.blockSize+0)))
        s.position = CGPoint(x: x*Double(Board.blockSize), y: -y*Double(Board.blockSize))
        s.fillColor = color
        s.strokeColor = UIColor.clear
        self.sprite = [s]
        
        if(direction + Board.direction % 2 == 0) {
            let arrow1 = SKShapeNode.init(path: getTrianglePath(corner: CGPoint(x: Double(Board.blockSize)*(1/3.0), y: Double(Board.blockSize)*((1/2.0) + (1/18.0))), rotation: 0.0, size: Double(Board.blockSize)*(1/3.0)))
            arrow1.strokeColor = UIColor.black
            arrow1.fillColor = UIColor.clear
            arrow1.lineWidth = 2.0
            let arrow2 = SKShapeNode.init(path: getTrianglePath(corner: CGPoint(x: Double(Board.blockSize)*(2/3.0), y: Double(Board.blockSize)*((1/2.0) - (1/18.0))), rotation: 180.0, size: Double(Board.blockSize)*(1/3.0)))
            arrow2.strokeColor = UIColor.black
            arrow2.fillColor = UIColor.clear
            arrow2.lineWidth = 2.0
            sprite[0].addChild(arrow1)
            sprite[0].addChild(arrow2)
        } else {
            let arrow1 = SKShapeNode.init(path: getTrianglePath(corner: CGPoint(x: Double(Board.blockSize)*((1/2.0) - (1/18.0)), y: Double(Board.blockSize)*(1/3.0)), rotation: 90.0, size: Double(Board.blockSize)*(1/3.0)))
            arrow1.strokeColor = UIColor.black
            arrow1.fillColor = UIColor.clear
            arrow1.lineWidth = 2.0
            let arrow2 = SKShapeNode.init(path: getTrianglePath(corner: CGPoint(x: Double(Board.blockSize)*((1/2.0) + (1/18.0)), y: Double(Board.blockSize)*(2/3.0)), rotation: -90.0, size: Double(Board.blockSize)*(1/3.0)))
            arrow2.strokeColor = UIColor.black
            arrow2.fillColor = UIColor.clear
            arrow2.lineWidth = 2.0
            sprite[0].addChild(arrow1)
            sprite[0].addChild(arrow2)
        }
    }
}
