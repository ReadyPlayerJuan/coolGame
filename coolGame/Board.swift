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
    
    static let defaultBlockSize: Double = Double(Int(GameState.screenHeight / 5.0))
    static var blockSize: Double = defaultBlockSize
    static var spawnPoint: CGPoint!
    static var colorTheme = 0
    static var direction = 0
    static let colorVariation = 30.0
    
    static var stageID = -1
    
    
    static let gray = CGFloat(0.25)
    static let backgroundColor = UIColor.init(red: gray, green: gray, blue: gray, alpha: 1.0)
    
    class func nextStage() {
        if(GameState.inEditor) {
            currentStage = Stage.loadStage(code: Memory.getStageEdit())
        } else if(GameState.testing) {
            blockSize = defaultBlockSize
            if(currentStage == nil) {
                loadAllStages()
                currentStage = Stage.loadTestingArea()
            } else {
                if(currentStage?.children.count != 0) {
                    currentStage = currentStage?.children[GameState.exitTarget]
                } else {
                    currentStage = Stage.loadTestingArea()
                }
            }
        } else {
            blockSize = defaultBlockSize
            if(currentStage == nil) {
                loadAllStages()
                let ID = Memory.getCurrentStageID()
                    
                if(ID == -1) {
                    currentStage = hubStage
                } else {
                    if(hubStage.findStageWithID(ID, baseID: hubStage.ID) != nil) {
                        currentStage = hubStage.findStageWithID(ID, baseID: hubStage.ID)
                    } else {
                        print("saved stage not found")
                        currentStage = hubStage
                    }
                }
            } else {
                if(currentStage?.children.count != 0) {
                    currentStage = currentStage?.children[GameState.exitTarget]
                } else {
                    currentStage = hubStage
                }
            }
        }
        
        colorTheme = currentStage!.colorTheme
        stageID = (currentStage?.ID)!
        Memory.saveCurrentStageID(ID: stageID)
        GameState.playerAbilities = currentStage!.playerAbilities
        Memory.saveAbilityUnlockProgress(progress: GameState.playerAbilities)
        
        direction = 0
        let temp: [[Int]]! = currentStage?.blocks
        spawnPoint = currentStage?.spawnPoint
        otherEntities = (currentStage?.getEntities())!
        
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
                } else if(temp[row][col] > -9 && temp[row][col] < -1) {
                    blocks[row][col] = Block.init(blockType: 2, color: (-temp[row][col])-2, secondaryColor: -1, dir: -1, x: Double(col), y: Double(row))
                    blocks[row][col]?.invert()
                } else if(temp[row][col] == 99) {
                    blocks[row][col] = Block.init(blockType: 6, color: -1, secondaryColor: -1, dir: -1, x: Double(col), y: Double(row))
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
    
    class func reset() {
        currentStage = nil
        direction = 0
        blocks = [[Block]]()
        otherEntities = [Entity]()
        colorTheme = 0
        blockSize = defaultBlockSize
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
                
                entity.rotate()
                
                entity.loadSprite()
                entity.updateSprite()
            }
            EntityManager.redrawEntities(node: GameState.drawNode, name: "all")
            
            let p = (EntityManager.getPlayer()! as! Player)
            var tempVels = [p.prevXVel, p.prevYVel]
            p.prevXVel = -tempVels[1]
            p.prevYVel = tempVels[0]
            
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
                
                entity.rotate()
                
                entity.loadSprite()
                entity.updateSprite()
            }
            EntityManager.redrawEntities(node: GameState.drawNode, name: "all")
            
            let p = (EntityManager.getPlayer()! as! Player)
            var tempVels = [p.prevXVel, p.prevYVel]
            p.prevXVel = tempVels[1]
            p.prevYVel = -tempVels[0]
            
            blocks = temp
         }
    }
    
    class func rotatePoint(_ point: CGPoint, clockwise: Bool) -> CGPoint {
        if(clockwise) {
            var tempCoords = [Double(point.x), Double(point.y)]
            var tempPoint = CGPoint()
            tempPoint.x = CGFloat(Double(blocks.count-1)-tempCoords[1])
            tempPoint.y = CGFloat(tempCoords[0])
            return tempPoint
        } else {
            var tempCoords = [Double(point.x), Double(point.y)]
            var tempPoint = CGPoint()
            tempPoint.x = CGFloat(tempCoords[1])
            tempPoint.y = CGFloat(Double(blocks[0].count-1)-tempCoords[0])
            return tempPoint
        }
    }
    
    class func sortOtherEntities() -> [Entity] {
        var temp = [Entity]()
        
        for e in otherEntities {
            var index = 0
            if(temp.count > 0) {
                while(index < temp.count && temp[index].y >= e.y) {
                    index += 1
                }
            }
            
            temp.insert(e, at: index)
        }
        for e in temp {
            print(e.y)
        }
        
        return temp
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
        let stage =   [ [1, 1, 1, 1, 1, 1, 1, 1, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 0, 0, 0, 0,-11,0, 0, 1],
                        [1, 1, 1, 1, 1, 1, 1, 1, 1] ]
        let spawnPoint = CGPoint(x: 3, y: 5)
        let exitTargets = [[5, 5, 0]]
        let otherEntities: [Entity] = []
        
        hubStage = Stage.init(withBlocks: stage, entities: otherEntities, spawn: spawnPoint, withName: "hub", exits: exitTargets, colorTheme: 1)
        StageSet1.loadStages(base: hubStage)
        //StageSet2.loadStages(base: hubStage)
    }
}
