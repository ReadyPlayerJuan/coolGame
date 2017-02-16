//
//  LightSource.swift
//  coolGame
//
//  Created by Nick Seel on 2/12/17.
//  Copyright © 2017 Nick Seel. All rights reserved.
//

import Foundation
import SpriteKit

class LightSource: Entity {
    var blockTransparency: [[Bool]] = [[]]
    var stageEdges: [LineSegment] = []
    var type: Int = 0
    
    init(type: Int, xPos: Double, yPos: Double) {
        super.init()
        
        self.type = type
        //0: stationary
        //1: locked onto player
        
        x = xPos
        y = yPos
        
        name = "light source"
        isDynamic = false
        collisionPriority = 0
        drawPriority = 15
        
        collidesWithType = [0, 10, 11, 12, 13, 14, 15]
        collisionType = 0
        
        loadSprite()
    }
    
    override func duplicate() -> Entity {
        return LightSource.init(type: type, xPos: x, yPos: y)
    }
    
    override func update(delta: TimeInterval) {
        updateSprite()
    }
    
    override func updateSprite() {
        sprite[0].removeAllChildren()
        
        var center = CGPoint()
        if(type == 0) {
            center = CGPoint(x: x, y: y)
        } else {
            let player = EntityManager.getPlayer() as! Player
            center = CGPoint(x: player.x + 0.5, y: player.y - ((sqrt(3.0)/2.0) * (2.0 / 3.0)))
        }
        
        for ls in stageEdges {
            ls.info = ls.distanceTo(point: center)
        }
        
        var sortedSegments = [LineSegment]()
        
        for ls in stageEdges {
            var index = 0
            if(sortedSegments.count > 0) {
                while(index < sortedSegments.count && sortedSegments[index].info < ls.info) {
                    index += 1
                }
            }
            sortedSegments.insert(ls, at: index)
        }
        if(stageEdges.count > 0) {
            //sortedSegments.append(stageEdges[0])
            //sortedSegments.append(stageEdges[1])
            //sortedSegments.append(stageEdges[2])
            //sortedSegments.append(stageEdges[3])
            //sortedSegments.append(stageEdges[6])
        }
        
        var s: SKShapeNode
        
        let size = CGFloat(Board.blockSize)
        let shadowDistance = CGFloat(400.0)
        
        for ls in sortedSegments {
            let point0 = ls.points[0]
            let point1 = ls.points[1]
            
            if(ls.points[0].x == ls.points[1].x) {
                let slope0 = -CGFloat(Double(point0.y - center.y) / Double(point0.x - center.x))
                let slope1 = -CGFloat(Double(point1.y - center.y) / Double(point1.x - center.x))
                
                let xMod = (point1.x - point0.x) * size
                let yMod = -(point1.y - point0.y) * size
                
                var distance0 = shadowDistance
                if(center.x > point0.x) {
                    distance0 *= -1
                }
                var distance1 = shadowDistance
                if(center.x > point1.x) {
                    distance1 *= -1
                }
                
                let b = UIBezierPath.init()
                b.move(to: CGPoint(x: 0, y: 0))
                b.addLine(to: CGPoint(x: 0 + xMod, y: 0 + yMod))
                
                b.addLine(to: CGPoint(x: xMod + (distance1), y: yMod + slope1 * (distance1)))
                b.addLine(to: CGPoint(x: (distance0), y: slope0 * (distance0)))
                
                
                s = SKShapeNode.init(path: b.cgPath)
            } else {
                let slope0 = -CGFloat(Double(point0.y - center.y) / Double(point0.x - center.x))
                let slope1 = -CGFloat(Double(point1.y - center.y) / Double(point1.x - center.x))
                
                let xMod = (point1.x - point0.x) * size
                let yMod = (point1.y - point0.y) * size
                
                var distance0 = shadowDistance
                if(center.x > point0.x) {
                    distance0 *= -1
                }
                var distance1 = shadowDistance
                if(center.x > point1.x) {
                    distance1 *= -1
                }
                
                let b = UIBezierPath.init()
                b.move(to: CGPoint(x: 0, y: 0))
                b.addLine(to: CGPoint(x: 0 + xMod, y: 0 + yMod))
                
                b.addLine(to: CGPoint(x: xMod + (distance1), y: yMod + slope1 * (distance1)))
                b.addLine(to: CGPoint(x: (distance0), y: slope0 * (distance0)))
                
                
                s = SKShapeNode.init(path: b.cgPath)
            }
            
            s.position = CGPoint(x: point0.x * size, y: -point0.y * size)
            s.fillColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
            s.strokeColor = UIColor.clear
            sprite[0].addChild(s.copy() as! SKShapeNode)
        }
    }
    
    override func loadSprite() {
        
    }
    
    func loadStageInfo() {
        let player = EntityManager.getPlayer() as! Player
        
        let width = Board.blocks[0].count
        let height = Board.blocks.count
        blockTransparency = newEmptyBoolArray(width: width, height: height)
        stageEdges = []
        
        for row in 0...Board.blocks.count-1 {
            for col in 0...Board.blocks[0].count-1 {
                if(type == 0) {
                    blockTransparency[row][col] = Entity.collides(this: self, with: Board.blocks[row][col]!)
                } else if(type == 1) {
                    blockTransparency[row][col] = Entity.collides(this: player, with: Board.blocks[row][col]!)
                }
            }
        }
        
        for row in 0...blockTransparency.count-1 {
            for col in 0...blockTransparency[0].count-1 {
                if(blockTransparency[row][col] == true) {
                    if(row > 0 && (blockTransparency[row-1][col] == false)) {
                        stageEdges.append(LineSegment.init(CGPoint(x: col, y: row-1), CGPoint(x: col+1, y: row-1)))
                    }
                    if(col > 0 && (blockTransparency[row][col-1] == false)) {
                        stageEdges.append(LineSegment.init(CGPoint(x: col, y: row), CGPoint(x: col, y: row-1)))
                    }
                    if(row < blockTransparency.count-1 && (blockTransparency[row+1][col] == false)) {
                        stageEdges.append(LineSegment.init(CGPoint(x: col, y: row), CGPoint(x: col+1, y: row)))
                    }
                    if(col < blockTransparency[0].count-1 && (blockTransparency[row][col+1] == false)) {
                        stageEdges.append(LineSegment.init(CGPoint(x: col+1, y: row), CGPoint(x: col+1, y: row-1)))
                    }
                }
            }
        }
        
        updateSprite()
    }
    
    private func newEmptyBoolArray(width: Int, height: Int) -> [[Bool]] {
        var temp = [[Bool]]()
        for row in 0 ... height-1 {
            temp.append([Bool]())
            for col in 0 ... width-1 {
                if(col != -69) {
                    temp[row].append(false)
                }
            }
        }
        return temp
    }
}
