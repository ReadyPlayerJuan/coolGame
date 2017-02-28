//
//  Particle.swift
//  coolGame
//
//  Created by Nick Seel on 2/24/17.
//  Copyright © 2017 Nick Seel. All rights reserved.
//

import Foundation
import SpriteKit

class Particle {
    var x: Double, y: Double, xVel: Double, yVel: Double
    var maxXVel: Double, maxYVel: Double
    var shape: Int
    var color: UIColor
    var lifeTime: Double
    var deathTimer: Double
    var deathType: Int
    
    let zPos = 101
    
    var sprite: SKShapeNode!
    
    init(x: Double, y: Double, xVel: Double, yVel: Double, shape: Int, color: UIColor, lifeTime: Double, deathType: Int) {
        self.x = x
        self.y = y
        self.xVel = xVel
        self.yVel = yVel
        maxXVel = xVel
        maxYVel = yVel
        self.shape = shape
        self.color = color
        self.lifeTime = lifeTime
        deathTimer = lifeTime
        self.deathType = deathType
        
        loadSprite()
    }
    
    func loadSprite() {
        let size = 0.1
        
        switch(shape) {
        case 0: //square
            sprite = SKShapeNode.init(rect: CGRect.init(x: -(size/2)*Board.blockSize, y: -(size/2)*Board.blockSize, width: size*Board.blockSize, height: size*Board.blockSize))
            break
        case 1: //triangle
            let height = size*(sqrt(3.0)/2.0)
            let path = UIBezierPath.init()
            path.move(to: CGPoint(x: -(size/2)*Board.blockSize, y: -(height/3)*Board.blockSize))
            path.addLine(to: CGPoint(x: (size/2)*Board.blockSize, y: -(height/3)*Board.blockSize))
            path.addLine(to: CGPoint(x: 0, y: (height/1.5)*Board.blockSize))
            sprite = SKShapeNode.init(path: path.cgPath)
            break
        default:
            break
        }
        
        sprite.fillColor = color
        sprite.strokeColor = UIColor.clear
        sprite.position = CGPoint.init(x: x*Board.blockSize, y: y*Board.blockSize)
    }
    
    func isAlive() -> Bool {
        return deathTimer > 0
    }
    
    func update(delta: TimeInterval) {
        deathTimer -= delta
        if(deathTimer < 0) {
            deathTimer = 0
        }
        
        x += xVel
        y += yVel
        
        switch(deathType) {
        case 0:
            let prog = (deathTimer / lifeTime)
            xVel = maxXVel * prog
            yVel = maxYVel * prog
            break
        default:
            break
        }
    }
}
