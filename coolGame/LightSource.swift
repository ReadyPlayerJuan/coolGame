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
        zPos = 15
        
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
        if(type == 099) {
            center = CGPoint(x: x+0.5, y: y-0.5)
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
        
        
        
        var confirmedSegments = [LineSegment]()
        var confirmedSegmentSpritePoints = [[CGPoint]]()
        
        for ls in sortedSegments {
            //confirmedSegments.append(ls)
            //confirmedSegmentSpritePoints.append(ls.points)
            var blockingSegments = [LineSegment]()
            var numVisiblePoints = 0
            
            for p in ls.points {
                var blocked = false
                
                if(confirmedSegments.count > 0) {
                    for ls2 in confirmedSegments {
                        if(!(p.x > center.x && (ls2.points[0].x < center.x && ls2.points[1].x < center.x)) &&
                            !(p.x < center.x && (ls2.points[0].x > center.x && ls2.points[1].x > center.x)) &&
                            !(p.y > center.y && (ls2.points[0].y < center.y && ls2.points[1].y < center.y)) &&
                            !(p.y < center.y && (ls2.points[0].y > center.y && ls2.points[1].y > center.y)) &&
                            linesIntersect(ls2, with: LineSegment.init(center, p))) {
                            blocked = true
                            
                            let a = CGFloat(0.0)
                            var pt: LineSegment!
                            let p0 = ls2.points[0]
                            let p1 = ls2.points[1]
                            if(ls2.vertical) {
                                if(ls2.points[0].y < ls2.points[1].y) {
                                    pt = LineSegment.init(CGPoint.init(x: p0.x, y: p0.y + a), CGPoint.init(x: p1.x, y: p1.y - a))
                                } else {
                                    pt = LineSegment.init(CGPoint.init(x: p0.x, y: p0.y - a), CGPoint.init(x: p1.x, y: p1.y + a))
                                }
                            } else {
                                if(ls2.points[0].x < ls2.points[1].x) {
                                    pt = LineSegment.init(CGPoint.init(x: p0.x + a, y: p0.y), CGPoint.init(x: p1.x - a, y: p1.y))
                                } else {
                                    pt = LineSegment.init(CGPoint.init(x: p0.x - a, y: p0.y), CGPoint.init(x: p1.x + a, y: p1.y))
                                }
                            }
                            blockingSegments.append(pt)
                        }
                    }
                }
                
                if(!blocked) {
                    numVisiblePoints += 1
                }
            }
            
            switch(numVisiblePoints) {
            case 0:
                // line segment is not visible
                break
            case 1:
                // part of the segment is visible
                
                var possibleSegments = [LineSegment]()
                
                for blockedBy in blockingSegments {
                    var points = [CGPoint]()
                    
                    for p in ls.points {
                        if(linesIntersect(blockedBy, with: LineSegment.init(center, p))) {
                            if(ls.vertical) {
                                if(linesIntersect(ls, with: LineSegment.init(center, blockedBy.points[0]))) {
                                    points.append(CGPoint.init(x: ls.points[0].x, y: getIntersectPosition(ls, with: LineSegment.init(center, blockedBy.points[0]))))
                                } else if(linesIntersect(ls, with: LineSegment.init(center, blockedBy.points[1]))) {
                                    points.append(CGPoint.init(x: ls.points[0].x, y: getIntersectPosition(ls, with: LineSegment.init(center, blockedBy.points[1]))))
                                }
                            } else {
                                if(linesIntersect(ls, with: LineSegment.init(center, blockedBy.points[0]))) {
                                    points.append(CGPoint.init(x: getIntersectPosition(ls, with: LineSegment.init(center, blockedBy.points[0])), y: ls.points[0].y))
                                } else if(linesIntersect(ls, with: LineSegment.init(center, blockedBy.points[1]))) {
                                    points.append(CGPoint.init(x: getIntersectPosition(ls, with: LineSegment.init(center, blockedBy.points[1])), y: ls.points[0].y))
                                }
                            }
                        } else {
                            points.append(p)
                        }
                    }
                    
                    
                    if(points.count == 2) {
                        possibleSegments.append(LineSegment.init(points[0], points[1]))
                    }
                }
                
                //choose smallest segment
                if(possibleSegments.count > 0) {
                    var smallestSegment = possibleSegments[0]
                    for s in possibleSegments {
                        if(s.distance < smallestSegment.distance) {
                            smallestSegment = s
                        }
                    }
                    
                    confirmedSegments.append(smallestSegment)
                    confirmedSegmentSpritePoints.append(smallestSegment.points)
                }
                break
            case 2:
                //all of the segment is visible
                confirmedSegments.append(ls)
                confirmedSegmentSpritePoints.append(ls.points)
                break
            default:
                break
            }
        }
        
        let size = CGFloat(Board.blockSize)
        
        let temp = SKShapeNode.init(rect: CGRect.init(x: -20, y: -20, width: 40, height: 40))
        temp.fillColor = UIColor.red
        temp.alpha = 0.5
        temp.position = CGPoint(x: (center.x * size), y: (-center.y * size))
        temp.zPosition = 1
        sprite[0].addChild(temp)
        
        var s: SKShapeNode
        
        
        for ls in confirmedSegments {
            let b = UIBezierPath.init()
            b.move(to: CGPoint(x: center.x * size, y: -center.y * size))
            b.addLine(to: CGPoint(x: ls.points[0].x * size, y: -ls.points[0].y * size))
            b.addLine(to: CGPoint(x: ls.points[1].x * size, y: -ls.points[1].y * size))
            
            s = SKShapeNode.init(path: b.cgPath)
            
            s.fillColor = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)
            s.strokeColor = UIColor.clear
            sprite[0].addChild(s.copy() as! SKShapeNode)
        }
        
        for ls in confirmedSegments {
            //let ls = confirmedSegments[20]
            let minX = min(ls.points[0].x, ls.points[1].x)*size
            let minY = min(ls.points[0].y, ls.points[1].y)*size
            let maxX = max(ls.points[0].x, ls.points[1].x)*size
            let maxY = max(ls.points[0].y, ls.points[1].y)*size
            
            s = SKShapeNode.init(rect: CGRect.init(x: minX-5, y: -maxY-5, width: maxX-minX+10, height: maxY-minY+10))
            s.fillColor = UIColor.green
            s.alpha = 0.4
            s.zPosition = 2
            sprite[0].addChild(s.copy() as! SKShapeNode)
        }
    }
    
    private func linesIntersect(_ this: LineSegment, with: LineSegment) -> Bool {
        if(this.vertical) {
            let slope = (with.points[1].y - with.points[0].y) / (with.points[1].x - with.points[0].x)
            let yPos = (slope * (this.points[0].x - with.points[0].x)) + with.points[0].y
            return ((yPos > this.points[0].y && yPos < this.points[1].y) || (yPos < this.points[0].y && yPos > this.points[1].y))
        } else {
            let slope = (with.points[1].x - with.points[0].x) / (with.points[1].y - with.points[0].y)
            let xPos = (slope * (this.points[0].y - with.points[0].y)) + with.points[0].x
            return ((xPos > this.points[0].x && xPos < this.points[1].x) || (xPos < this.points[0].x && xPos > this.points[1].x))
        }
    }
    
    private func getIntersectPosition( _ this: LineSegment, with: LineSegment) -> CGFloat {
        if(this.vertical) {
            let slope = (with.points[1].y - with.points[0].y) / (with.points[1].x - with.points[0].x)
            let yPos = (slope * (this.points[0].x - with.points[0].x)) + with.points[0].y
            return yPos
        } else {
            let slope = (with.points[1].x - with.points[0].x) / (with.points[1].y - with.points[0].y)
            let xPos = (slope * (this.points[0].y - with.points[0].y)) + with.points[0].x
            return xPos
        }
    }
    
    override func loadSprite() {
        sprite[0].zPosition = zPos
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
