//
//  Board.swift
//  TestGame
//
//  Created by Erin Seel on 11/24/16.
//  Copyright © 2016 Nick Seel. All rights reserved.
//

import Foundation
import GameplayKit

class Board {
    static var hubStage: Stage!
    static var currentStage: Stage?
    
    static var blocks: [[Block?]]!
    static var otherEntities: [Entity] = []
    
    static var blockSize = 75
    static var spawnPoint: CGPoint!
    static var colorTheme = 0
    static var direction = 0
    static let colorVariation = 25.0
    
    static var stageNum = -1
    
    static let blackBlockCategory: UInt32 = UInt32(exactly: 0)!
    static let whiteBlockCategory: UInt32 = UInt32(exactly: 1)!
    static let playerCategory: UInt32 = UInt32(exactly: 99)!
    
    static let gray = CGFloat(0.15)
    static let backgroundColor = UIColor.init(red: gray, green: gray, blue: gray, alpha: 1.0)
    
    class func nextStage() {
        if(currentStage == nil) {
            loadAllStages()
            currentStage = hubStage
        } else {
            if(currentStage?.children.count != 0) {
                currentStage = currentStage?.children[GameState.exitTarget]
            } else {
                currentStage = hubStage
            }
        }
        
        let temp: [[Int]]! = currentStage?.blocks
        spawnPoint = currentStage?.spawnPoint
        otherEntities = (currentStage?.otherEntities)!
        direction = 0
        
        //Player.reset()
        
        blocks = newEmptyArray(width: temp[0].count, height: temp.count)
        
        for row in 0 ... blocks.count-1 {
            for col in 0 ... blocks[0].count-1 {
                if(temp[row][col] == -9) {
                    blocks[row][col] = Block.init(blockType: 5, color: -1, secondaryColor: -1, dir: -1, x: Double(col), y: Double(row))
                } else if(temp[row][col] == 1 || temp[row][col] == 0) {
                    blocks[row][col] = Block.init(blockType: temp[row][col], color: -1, secondaryColor: -1, dir: -1, x: Double(col), y: Double(row))
                } else if(temp[row][col] < 10 && temp[row][col] > 1) {
                    blocks[row][col] = Block.init(blockType: 2, color: temp[row][col]-2, secondaryColor: -1, dir: -1, x: Double(col), y: Double(row))
                } else if(temp[row][col] >= 10) {
                    let s = temp[row][col]
                    let direction = Int(Double(s)/100.0)
                    var colorIndex = Int(Double(s-(100*direction))/10.0)
                    var colorIndex2 = s - (100*direction) - (colorIndex*10)
                    colorIndex -= 2
                    colorIndex2 -= 2
                    blocks[row][col] = Block.init(blockType: 3, color: colorIndex, secondaryColor: colorIndex2, dir: direction, x: Double(col), y: Double(row))
                } else if(temp[row][col] < 0) {
                    blocks[row][col] = Block.init(blockType: 4, color: (abs(temp[row][col])%10)-2, secondaryColor: -1, dir: (abs(temp[row][col])/10)-1, x: Double(col), y: Double(row))
                    for coords in (currentStage?.exitTargets)! {
                        if(col == coords[0] && row == coords[1]) {
                            blocks[row][col]?.exitTarget = coords[2]
                        }
                    }
                }
            }
        }
    }
    
    class func loadFreshStage() {
        stageNum = -2
        nextStage()
    }
    
    class func rotate() {
         if(GameState.rotateDirection == "right") {
            direction += 1
            direction %= 4
            
            var temp = newEmptyArray(width: blocks.count, height: blocks[0].count)
            for row in 0 ... blocks[0].count-1 {
                for c in 0 ... blocks.count-1 {
                    let col = blocks.count-1 - c
                    temp[row][col] = blocks[blocks.count-1-col][row]
                }
            }
            
            for entity in EntityManager.entities {
                var tempCoords = [entity.x, entity.y]
                entity.x = Double(blocks.count-1)-tempCoords[1]
                entity.y = tempCoords[0]
                
                entity.nextX = entity.x
                entity.nextY = entity.y
                
                let temp = entity.xVel
                entity.xVel = entity.yVel * -1
                entity.yVel = temp
                
                entity.loadSprite()
            }
            EntityManager.redrawEntities(node: GameState.drawNode, name: "all")
            
            blocks = temp
         } else {
            direction -= 1
            if(direction < 0) {
                direction += 4
            }
            
            var temp = newEmptyArray(width: blocks.count, height: blocks[0].count)
            for row in 0 ... blocks[0].count-1 {
                for col in 0 ... blocks.count-1 {
                    temp[row][col] = blocks[col][blocks[0].count-1-row]
                }
            }
            
            for entity in EntityManager.entities {
                var tempCoords = [entity.x, entity.y]
                entity.x = tempCoords[1]
                entity.y = Double(blocks[0].count-1)-tempCoords[0]
                
                entity.nextX = entity.x
                entity.nextY = entity.y
                
                let temp = entity.xVel
                entity.xVel = entity.yVel
                entity.yVel = temp * -1
                
                entity.loadSprite()
            }
            EntityManager.redrawEntities(node: GameState.drawNode, name: "all")
            
            blocks = temp
         }
    }
    
    private class func newEmptyArray(width: Int, height: Int) -> [[Block?]] {
        var temp = [[Block?]]()
        for row in 0 ... height-1 {
            temp.append([Block]())
            for col in 0 ... width-1 {
                if(col != -69) {
                    temp[row].append(nil)
                }
            }
        }
        return temp
    }
    
    private class func loadAllStages() {
        let stage =   [ [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0,-11,0, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 4, 0, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 4, 0, 1],
                        [1, 0, 0, 0, 0, 0, 3, 0, 4, 0, 1],
                        [1, 0, 0, 0, 0, 0, 3, 0, 0, 0, 1],
                        [1, 0,-21,2, 2, 0, 3, 0, 0, 0, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1] ]
        let spawnPoint = CGPoint(x: 1, y: 6)
        let exitTargets = [[2, 6, 0], [8, 1, 1]]
        let otherEntities = [MovingBlock.init(color: 1, dir: 1, xPos: 3, yPos: 5)]
        
        hubStage = Stage.init(withBlocks: stage, entities: otherEntities, spawn: spawnPoint, withName: "hub", exits: exitTargets)
        StageSet1.loadStages(base: hubStage)
        StageSet2.loadStages(base: hubStage)
    }
}
