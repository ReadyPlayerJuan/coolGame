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
    static var blocks: [[Block?]]!
    static var blockSize = 75
    static var spawnPoint: CGPoint!
    static var colorTheme = 0
    static var direction = 0
    static let colorVariation = 20.0
    
    static var stageNum = -1
    
    static var endBlock: Block!
    static var endBlockLayer: CALayer!
    static var endBlockPoint: CGPoint!
    
    static let blackBlockCategory: UInt32 = UInt32(exactly: 0)!
    static let whiteBlockCategory: UInt32 = UInt32(exactly: 1)!
    static let playerCategory: UInt32 = UInt32(exactly: 99)!
    
    static let gray = CGFloat(0.15)
    static let backgroundColor = UIColor.init(red: gray, green: gray, blue: gray, alpha: 1.0)
    
    class func nextStage() {
        stageNum += 1
        direction = 0
        var temp = getStage(index: stageNum)
        
        //Player.reset()
        
        blocks = newEmptyArray(width: temp[0].count, height: temp.count)
        
        for row in 0 ... blocks.count-1 {
            for col in 0 ... blocks[0].count-1 {
                if(temp[row][col] == -9) {
                    blocks[row][col] = Block.init(blockType: 5, color: -1, secondaryColor: -1, dir: -1, x: Double(col), y: Double(row))
                } else if(temp[row][col] == 1 || temp[row][col] == 0) {
                    blocks[row][col] = Block.init(blockType: temp[row][col], color: -1, secondaryColor: -1, dir: -1, x: Double(col), y: Double(row))                } else if(temp[row][col] < 10 && temp[row][col] > 1) {
                    blocks[row][col] = Block.init(blockType: 2, color: temp[row][col]-2, secondaryColor: -1, dir: -1, x: Double(col), y: Double(row))                } else if(temp[row][col] >= 10) {
                    let s = temp[row][col]
                    let direction = Int(Double(s)/100.0)
                    var colorIndex = Int(Double(s-(100*direction))/10.0)
                    var colorIndex2 = s - (100*direction) - (colorIndex*10)
                    colorIndex -= 2
                    colorIndex2 -= 2
                    blocks[row][col] = Block.init(blockType: 3, color: colorIndex, secondaryColor: colorIndex2, dir: direction, x: Double(col), y: Double(row))                } else if(temp[row][col] < 0) {
                    blocks[row][col] = Block.init(blockType: 4, color: (abs(temp[row][col])%10)-2, secondaryColor: -1, dir: (abs(temp[row][col])/10)-1, x: Double(col), y: Double(row))
                    endBlockPoint = CGPoint(x: col*blockSize, y: row*blockSize)
                    endBlock = blocks[row][col]
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
                
                entity.loadSprite()
            }
            EntityManager.redrawEntities(node: GameState.drawNode, name: "all")
            
            blocks = temp
         }
    }
    
    
    //class func drawBlocks(layer: CALayer, time: TimeInterval) {
    /*
     for row in 0 ... blocks.count-1 {
     for col in 0 ... blocks[0].count-1 {
     if(blocks[row][col]?.type == 4) {
     //let x = (Double(col)-(Double(blocks[0].count-1)/2.0))
     //let y = (Double(row)-(Double(blocks.count-1)/2.0))
     //let x = Double(col)
     //let y = Double(row)
     
     var index = 0
     for l in (blocks[row][col]?.getSpriteLayer())! {
     if(index == 0) {
     layer.addSublayer(l)
     /*
     l.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize(width: blockSize, height: blockSize))
     l.physicsBody?.isDynamic = false
     l.physicsBody?.restitution = 0.0
     node.addChild(l)*/
     } else {
     if(endBlockLayer == nil) {
     endBlockLayer = l
     }
     }
     
     index += 1
     }
     } else {
     //let x = (Double(col)-(Double(blocks[0].count-1)/2.0))
     //let y = (Double(row)-(Double(blocks.count-1)/2.0))
     //let x = Double(col)
     //let y = Double(row)
     
     for l in (blocks[row][col]?.getSpriteLayer())! {
     /*
     l.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize(width: blockSize, height: blockSize))
     l.physicsBody?.isDynamic = false
     l.physicsBody?.restitution = 0.0*/
     //node.addChild(l)
     layer.addSublayer(l)
     }
     }
     }
     }*/
    //}
    
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
    
    private class func getStage(index: Int) -> [[Int]] {
        var stage: [[Int]]? = nil
        
        switch(index) {
        case 0:
            stage =   [ [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1],
                        [1, 0, 0, 0, 0, 0, 0,-11, 0, 0, 0, 0, 0, 1],
                        [1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1] ]
            spawnPoint = CGPoint(x: 3, y: 4)
            
        case 1:
            stage =   [ [-9,-9,-9,-9,-9,-9,-9,1, 1, 1, 1, 1, 1],
                        [-9,-9,-9,-9,-9,-9,-9,1, 0, 0,-31,0, 1],
                        [-9,-9,-9,-9,1, 1, 1, 1, 0, 0, 0, 0, 1],
                        [-9,-9,-9,-9,1, 0, 0, 0, 0, 0, 0, 0, 1],
                        [-9,-9,-9,-9,1, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 1,-9,-9,-9,-9],
                        [1, 0, 0, 0, 0, 0, 0, 0, 1,-9,-9,-9,-9],
                        [1, 0, 0, 0, 0, 1, 1, 1, 1,-9,-9,-9,-9],
                        [1, 0, 0, 0, 0, 1,-9,-9,-9,-9,-9,-9,-9],
                        [1, 1, 1, 1, 1, 1,-9,-9,-9,-9,-9,-9,-9] ]
            spawnPoint = CGPoint(x: 2, y: 9); break
        case 2:
            stage =   [ [1, 1, 1, 1, 1, 1, 1, 1, 1,-9,-9, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                        [1, 0, 0, 0, 0, 0,212,0, 1,-9,-9, 1, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 4, 4, 0, 0, 0, 1],
                        [1, 0, 3, 0, 0, 0, 0, 0, 3, 2, 2, 3, 0, 0, 0, 0, 0, 4, 0, 1],
                        [1, 0, 0, 0, 1,314,0, 0, 3, 2, 2, 3, 0, 4, 0, 0,-21,4, 0, 1],
                        [1, 0, 2, 0, 0, 0, 0, 0, 3, 2, 2, 3, 0, 4, 0, 0, 0, 0, 0, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 4, 4, 0, 0, 1],
                        [1, 0, 0, 0, 0, 0,013,0, 1,-9,-9, 1, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 1, 1, 1, 1, 1, 1, 1, 1,-9,-9, 1, 1, 1, 1, 1, 1, 1, 1, 1] ]
            colorTheme = 0
            spawnPoint = CGPoint(x: 4, y: 6); break
        case 3:
            stage =   [ [1, 1, 1, 1, 1, 1, 1, 1, 1,-9,-9, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 1,-9,-9, 1, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 0, 3, 0, 0, 0, 3, 0, 1, 1, 1, 1, 0, 4, 0, 0, 0, 4, 0, 1],
                        [1, 0, 0, 0, 3, 0, 0, 0, 5, 4, 2, 5, 0, 0, 0,017,0, 0, 0, 1],
                        [1, 0, 3, 0,214,0, 3, 0, 5, 4, 2, 5, 0, 0,117,4,317,0, 0, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 5, 4, 2, 5, 0, 0, 0,217,0, 0, 0, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 4, 0, 0, 0, 4, 0, 1],
                        [1, 0, 0, 0, 0, 0,012,0, 1,-9,-9, 1, 0, 0, 0,014,0, 0, 0, 1],
                        [1, 1, 1, 4, 4, 4, 1, 1, 1,-9,-9, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                        [-9,-9, 1, 6, 6, 6, 1,-9,-9,-9,-9,-9,-9,-9,-9,-9,-9,-9,-9,-9],
                        [-9,-9, 1, 6, 6, 6, 1,-9,-9,-9,-9,-9,-9,-9,-9,-9,-9,-9,-9,-9],
                        [1, 1, 1, 4, 4, 4, 1, 1, 1,-9,-9, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                        [1, 2, 0, 0, 0, 0, 0, 5, 1,-9,-9, 1, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 0, 2, 2, 5, 5, 5, 0, 1, 1, 1, 1, 0, 6, 7, 2, 3, 4, 0, 1],
                        [1, 0, 2, 0, 0, 0, 5, 0, 3, 2, 2, 3, 0, 2, 3, 4, 5, 6, 0, 1],
                        [1, 0, 2,115,2,313,2, 0, 3, 2, 2, 3, 0, 4, 5,-26,7, 2, 0, 1],
                        [1, 0, 5, 0, 0, 0, 2, 0, 3, 2, 2, 3, 0, 6, 7, 2, 3, 4, 0, 1],
                        [1, 0, 5, 5, 5, 2, 2, 0, 1, 1, 1, 1, 0, 2, 3, 4, 5, 6, 0, 1],
                        [1, 5, 0, 0, 0, 0, 0, 2, 1,-9,-9, 1, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 1, 1, 1, 1, 1, 1, 1, 1,-9,-9, 1, 1, 1, 1, 1, 1, 1, 1, 1] ]
            colorTheme = 0
            spawnPoint = CGPoint(x: 2, y: 6); break
        case 4:
            stage =   [ [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 0, 0, 0, 0, 0, 0, 4, 3, 4, 4, 4, 0, 0, 0, 5, 0, 0, 1],
                        [1, 0, 6, 0, 2, 0, 0, 3, 2, 4, 0, 4, 5, 5, 0, 0, 0, 0, 1],
                        [1, 0, 0, 2, 0, 4, 0, 2,263,0, 5, 3, 0, 4, 0, 3, 0, 0, 1],
                        [1, 0, 0, 6, 0, 4, 0, 5, 0, 0, 0, 5, 6, 4, 3, 0, 0, 0, 1],
                        [1, 0, 0, 0, 0, 6, 5,376,0, 0, 3, 0, 0, 0, 0, 4, 0, 0, 1],
                        [1, 0, 0, 4, 0, 0, 6,164,3, 5, 2, 0, 3, 0, 6, 4, 0, 0, 1],
                        [1, 0, 0, 4, 0, 0, 2, 4, 3, 3, 2, 2, 0, 4, 6, 0, 0, 0, 1],
                        [1, 0, 0, 0, 0, 2, 0, 4, 0, 0, 0, 0,-27,265,0,0, 0, 0, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 0, 0, 1, 1, 0, 0,012,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1] ]
            colorTheme = 1
            spawnPoint = CGPoint(x: 2, y: 10); break
        default:
            stage =       [ [1, 1, 1, 1, 1],
                            [1, 0, 0, 0, 1],
                            [1, 0, 0, 0, 1],
                            [1, 0, 0,-11,1],
                            [1, 1, 1, 1, 1] ]
            spawnPoint = CGPoint(x: 1, y: 3); break
        }
        
        return stage!
    }
}
