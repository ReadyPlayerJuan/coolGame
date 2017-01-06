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
    
    init(dir: Int, xPos: Double, yPos: Double) {
        super.init()
        
        direction = dir
        x = xPos
        y = yPos
        
        name = "moving block"
        isDynamic = true
        collisionType = 0
        collidesWithType = [0]
        collisionPriority = 10
        drawPriority = 10
        
        loadSprite()
    }
    
    override func update(delta: TimeInterval) {
        if((Board.direction + direction) % 2 == 0) {
            yVel += GameState.gravity * delta
        }
        
        sprite[0].position = CGPoint(x: x * Double(Board.blockSize), y: -y * Double(Board.blockSize))
        
        super.update(delta: delta)
    }
    
    override func checkForCollision(with: [Entity]) {
        for entity in with {
            if(entityCollides(this: self, with: entity)) {
                
                let colAcc = 0.001
                
                if(yVel > 0) {
                    if(rectContainsPoint(rect: CGRect.init(x: entity.nextX, y: entity.nextY-1, width: 1.0, height: 1.0), point: CGPoint(x: x + colAcc, y: nextY)) || rectContainsPoint(rect: CGRect.init(x: entity.nextX, y: entity.nextY-1, width: 1.0, height: 1.0), point: CGPoint(x: x + 1 - colAcc, y: nextY)) )  {
                        
                        nextY = entity.nextY - 1
                        yVel = 0
                        
                        //print(" \(nextY)")
                        //print(" hit ground, with block at \(Int(entity.x)), \(Int(entity.y))")
                    }
                }
            }
        }
    }
    
    override func loadSprite() {
        let s = SKShapeNode.init(rect: CGRect.init(x: 0, y: 0, width: Double(Board.blockSize+1), height: Double(Board.blockSize+1)))
        s.position = CGPoint(x: x*Double(Board.blockSize), y: -y*Double(Board.blockSize))
        s.fillColor = UIColor.purple
        s.strokeColor = UIColor.clear
        self.sprite = [s]
    }
}
