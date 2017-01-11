//
//  Block.swift
//  Drawing Test
//
//  Created by Erin Seel on 11/25/16.
//  Copyright © 2016 Nick Seel. All rights reserved.
//

import Foundation
import SpriteKit

class Block: Entity {
    var colorIndex: Int = -1
    var colorIndex2: Int = -1
    var type: Int = 1
    var solid: Bool = true
    var direction: Int = 0
    var color: UIColor = UIColor.purple
    var dangerous = false
    
    var exitTarget: Int?
    
    init(blockType: Int, color: Int, secondaryColor: Int, dir: Int, x: Double, y: Double) {
        super.init()
        self.x = x
        self.y = y
        type = blockType
        
        isDynamic = false
        collidesWithType = [0]
        collisionPriority = 99
        name = "block"
        drawPriority = 1
        
        switch(type) {
        case 0: //black nonsolid block
            solid = false
            colorIndex = -1
            colorIndex2 = -1
            direction = -1
            collisionType = -1
            break
        case 1: //white solid block
            solid = true
            colorIndex = -1
            colorIndex2 = -1
            direction = -1
            collisionType = 0
            break
        case 2: //colored block
            solid = false
            colorIndex = color
            colorIndex2 = -1
            direction = -1
            collisionType = colorIndex + 10
            break
        case 3: //triangle block
            solid = false
            colorIndex = color
            colorIndex2 = secondaryColor
            direction = dir
            collisionType = colorIndex + 10
            break
        case 4: //end block
            solid = false
            colorIndex = color
            colorIndex2 = -1
            direction = dir
            collisionType = -1
            break
        case 5: //empty filler block
            solid = true
            colorIndex = -1
            colorIndex2 = -1
            direction = -1
            collisionType = 0
            break
        case 6: //hazard block
            solid = true
            colorIndex = -1
            colorIndex2 = -1
            direction = -1
            collisionType = 0
            break
        default: //white solid block
            solid = true
            colorIndex = -1
            colorIndex2 = -1
            direction = -1
            collisionType = 0
            break
        }
        
        initColor()
        loadSprite()
    }
    
    func initColor() {
        //var color = UIColor.purple
        if(type == 0 || type == 1 || (type == 3 && colorIndex == -1) || (type == 4 && colorIndex == -1)) {
            let blockVariation = Int(rand()*Board.colorVariation)
            
            if(type == 0 || ((type == 3 || type == 4) && colorIndex == -1)) {
                color = UIColor(red: 0.0+(CGFloat(blockVariation)/255.0), green: 0.0+(CGFloat(blockVariation)/255.0), blue: 0.0+(CGFloat(blockVariation)/255.0), alpha: 1.0)
            } else {
                color = UIColor(red: 1.0-(CGFloat(blockVariation)/255.0), green: 1.0-(CGFloat(blockVariation)/255.0), blue: 1.0-(CGFloat(blockVariation)/255.0), alpha: 1.0)
            }
        } else if(type == 2 || type == 3 || type == 4) {
            let n = 1.0
            let blockVariation = Int((Board.colorVariation*n) - (rand()*Board.colorVariation*2*n))
            var colorArray = ColorTheme.colors[Board.colorTheme][colorIndex]
            
            for index in 0 ... 2 {
                colorArray[index] = max(min(colorArray[index] + blockVariation, 255), 0)
            }
            
            color = UIColor(red: CGFloat(colorArray[0]) / 255.0, green: CGFloat(colorArray[1]) / 255.0, blue: CGFloat(colorArray[2]) / 255.0, alpha: 1.0)
        } else if(type == 5) {
            color = Board.backgroundColor
        }
        //print(color)
        //col = color
    }
    
    /*
    override func update(delta: TimeInterval) {
        super.update(delta: delta)
        updateSprite()
    }*/
    
    override func updateSprite() {
        if(type == 4) {
            let cycle = 1.0
            var b = GameState.time
            
            let a = Double(Int(b/cycle))*cycle
            let c = b - a
            b = c
            
            b /= cycle
            b *= 2
            b = b - 1
            b = pow(abs(b), 1.0)
            
            let otherColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: CGFloat(b))
            
            sprite[1].fillColor = otherColor
            //sprite[1]
        }
    }
    
    override func loadSprite() {
        if(type == 0 || type == 1 || type == 2 || type == 5) {
            let s = SKShapeNode.init(rect: CGRect.init(x: 0, y: 0, width: Double(Board.blockSize+0), height: Double(Board.blockSize+0)))
            s.position = CGPoint(x: x*Double(Board.blockSize), y: -y*Double(Board.blockSize))
            s.fillColor = color
            s.strokeColor = UIColor.clear
            self.sprite = [s]
        } else if(type == 3 || type == 4) {
            
            var point = CGPoint()
            point = CGPoint(x: x, y: y);
            
            var k = Board.direction - direction
            k %= 4
            if(k < 0) {
                k += 4
            }
            
            let unmodified = CGPoint(x: x, y: y)
            
            switch(k) {
            case 0:
                point = CGPoint(x: x, y: y); break
            case 1:
                point = CGPoint(x: x, y: y - 1); break
            case 2:
                point = CGPoint(x: x + 1, y: y - 1); break
            case 3:
                point = CGPoint(x: x + 1, y: y); break
            default:
                point = CGPoint(x: x, y: y); break
            }
            
            if(type == 4) {
                let s = SKShapeNode.init(rect: CGRect.init(x: 0, y: 0, width: Double(Board.blockSize+0), height: Double(Board.blockSize+0)))
                s.position = CGPoint(x: unmodified.x*CGFloat(Board.blockSize), y: -unmodified.y*CGFloat(Board.blockSize))
                s.fillColor = color
                s.strokeColor = UIColor.clear
                
                let s2 = SKShapeNode.init(path: getTrianglePath(corner: CGPoint(x: 0, y: 0), rotation: -90.0 * Double(Board.direction - direction), size: Double(Board.blockSize)))
                s2.position = CGPoint(x: point.x*CGFloat(Board.blockSize), y: -point.y*CGFloat(Board.blockSize))
                //s2.fillColor = UIColor.purple //color is set in updateSprite()
                s2.strokeColor = UIColor.clear
                
                self.sprite = [s, s2]
                
                updateSprite()
            } else {
                let color2 = UIColor(red: CGFloat(ColorTheme.colors[Board.colorTheme][colorIndex2][0])/255.0, green: CGFloat(ColorTheme.colors[Board.colorTheme][colorIndex2][1])/255.0, blue: CGFloat(ColorTheme.colors[Board.colorTheme][colorIndex2][2])/255.0, alpha: 1.0)
                
                let s = SKShapeNode.init(rect: CGRect.init(x: 0, y: 0, width: Double(Board.blockSize+0), height: Double(Board.blockSize+0)))
                s.position = CGPoint(x: unmodified.x*CGFloat(Board.blockSize), y: -unmodified.y*CGFloat(Board.blockSize))
                s.fillColor = color
                s.strokeColor = UIColor.clear
                
                let s2 = SKShapeNode.init(path: getTrianglePath(corner: CGPoint(x: 0, y: 0), rotation: -90.0 * Double(Board.direction - direction), size: Double(Board.blockSize)))
                s2.position = CGPoint(x: point.x*CGFloat(Board.blockSize), y: -point.y*CGFloat(Board.blockSize))
                s2.fillColor = color2
                s2.strokeColor = UIColor.clear
                
                self.sprite = [s, s2]
            }
        }
    }
}
