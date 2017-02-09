//
//  Entity.swift
//  another test game
//
//  Created by Nick Seel on 12/10/16.
//  Copyright © 2016 Nick Seel. All rights reserved.
//

import Foundation
import SpriteKit

class Entity {
    var x = 0.0, y = 0.0, xVel = 0.0, yVel = 0.0
    var isDynamic = true
    var collisionType = 0
    var collidesWithType = [0]
    var collisionPriority = 0
    var drawPriority = 0
    var isDangerous = false
    
    var name = ""
    
    var controllable = false
    var nextX = 0.0, nextY = 0.0
    
    var ID: Int = 0
    
    var sprite: [SKShapeNode] = [SKShapeNode()]
    
    init() {
        ID = EntityManager.getID()
    }
    
    func update(delta: TimeInterval) {
        nextX = x + xVel
        nextY = y + yVel
    }
    func checkForCollision(with: [Entity]) {}
    func move() {
        x = nextX
        y = nextY
        updateSprite()
    }
    
    func entityCollides(this: Entity, with: Entity) -> Bool {
        return (arrayContains(array: this.collidesWithType, number: with.collisionType))
            //|| arrayContains(array: with.collidesWithType, number: this.collisionType))
    }
    
    private func arrayContains(array: [Int], number: Int) -> Bool {
        for i in array {
            if(i == number) {
                return true
            }
        }
        return false
    }
    
    func rectContainsPoint(rect: CGRect, point: CGPoint) -> Bool {
        return (point.x >= rect.minX && point.x <= rect.maxX && point.y >= rect.minY && point.y <= rect.maxY)
    }
    
    func updateSprite() {}
    
    func loadSprite() {
        sprite = [SKShapeNode()]
    }
    
    func getSpriteLayer() -> [SKShapeNode] {
        return sprite
    }
    
    func rand() -> Double {
        return Double(arc4random())/(pow(2.0, 32.0)-1)
    }
}
