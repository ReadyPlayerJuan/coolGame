//
//  EntityManager.swift
//  another test game
//
//  Created by Nick Seel on 12/10/16.
//  Copyright © 2016 Nick Seel. All rights reserved.
//

import Foundation
import SpriteKit

class EntityManager {
    static var entities: [Entity] = []
    static var entitiesByCollisionPriority: [Entity] = []
    static var nextID = 0
    static let collisionRadius = 2.0
    static var collisionIterations = 2
    
    static func addEntity(entity: Entity) {
        entities.append(entity)
        entity.update(delta: 0.0)
    }
    
    static func updateEntities(delta: TimeInterval) {
        if let p = (EntityManager.getPlayer()) {
            let vel = hypot(p.xVel, p.yVel)
            if(vel > 2) {
                collisionIterations = Int(vel)
            }
        }
        for _ in 0...collisionIterations-1 {
            for e in entities {
                e.update(delta: delta / Double(collisionIterations))
            }
            checkForCollision()
        }
    }
    
    static func checkForCollision() {
        for e in entitiesByCollisionPriority {
            if(e.isDynamic) {// && e.name != "moving block") {
                e.checkForCollision(with: getEntitiesNear(entity: e, radius: collisionRadius))
            }
        }
        
        moveEntities()
    }
    
    static func moveEntities() {
        for e in entities {
            if(e.isDynamic) {
                e.move()
            }
        }
    }
    
    static func updateEntitySprites() {
        for e in entities {
            e.updateSprite()
        }
    }
    
    static func redrawEntities(node: SKShapeNode, name: String) {
        if(name == "all") {
            if(node.children.count != 0) {
                for sprite in node.children {
                    sprite.removeFromParent()
                }
            }
            
            for e in entities {
                for sprite in e.getSpriteLayer() {
                    node.addChild(sprite)
                }
            }
        } else if(name == "player") {
            node.addChild(EntityManager.getPlayer()!.sprite[0])
        }
    }
    
    static func reloadBlocks() {
        var temp = [Entity]()
        for e in entities {
            if(e.name != "block") {
                temp.append(e)
            }
        }
        entities = temp
        
        for row in 0 ... Board.blocks.count-1 {
            for col in 0 ... Board.blocks[0].count-1 {
                addEntity(entity: Board.blocks[row][col]!)
            }
        }
    }
    
    static func reloadAllEntities() {
        for e in entities {
            e.removeSpriteFromParent()
            e.loadSprite()
        }
        redrawEntities(node: GameState.drawNode, name: "all")
    }
    
    static func getEntitiesNear(entity: Entity, radius: Double) -> [Entity] {
        var temp = [Entity]()
        
        for e in entities {
            if(hypot(e.x - entity.x, e.y - entity.y) <= radius
                    && e.ID != entity.ID && entity.collisionPriority <= e.collisionPriority) {
                temp.append(e)
            }
        }
        
        return temp
    }
    
    static func sortEntities() {
        entitiesByCollisionPriority = sortEntitiesByCollisionPriority()
    }
    
    static func sortEntitiesByCollisionPriority() -> [Entity] {
        var temp = [Entity]()
        
        for e in entities {
            var index = 0
            if(temp.count > 0) {
                while(index < temp.count && temp[index].collisionPriority > e.collisionPriority) {
                    index += 1
                }
            }
            
            temp.insert(e, at: index)
        }
        
        return temp
    }
    
    static func getPlayer() -> Entity? {
        for e in entities {
            if(e.controllable) {
                return e
            }
        }
        print("no player found")
        return nil
    }
    
    static func loadLightSources() {
        for e in entities {
            if(e.name == "light source") {
                (e as! LightSource).loadStageInfo()
            }
        }
    }
    
    static func getID() -> Int {
        nextID += 1
        return nextID
    }
}
