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
    
    /*
     func isSolid() -> Bool {
     if(type == 0 || type == 1) {
     return solid
     }
     if(type == 2) {
     return Player.colorIndex == -1 || Player.colorIndex == colorIndex
     }
     if(type == 3) {
     return colorIndex != -1 && (Player.colorIndex == -1 || Player.colorIndex == colorIndex)
     }
     if(type == 4) {
     return colorIndex != -1 && (Player.colorIndex == -1 || Player.colorIndex == colorIndex)
     }
     if(type == 5) {
     return true
     }
     return true
     }*/
    
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
            let blockVariation = Int((Board.colorVariation/2.0) - (rand()*Board.colorVariation))
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
    
    override func loadSprite() {
        if(type == 0 || type == 1 || type == 2 || type == 5) {
            let s = SKShapeNode.init(rect: CGRect.init(x: 0, y: 0, width: Double(Board.blockSize+1), height: Double(Board.blockSize+1)))
            s.position = CGPoint(x: x*Double(Board.blockSize), y: -y*Double(Board.blockSize))
            s.fillColor = color
            s.strokeColor = UIColor.clear
            self.sprite = [s]
        } else if(type == 3 || type == 4) {
            
            var point = CGPoint()
            point = CGPoint(x: x*Double(Board.blockSize), y: y*Double(Board.blockSize));
            
            var k = Board.direction - direction
            k %= 4
            if(k < 0) {
                k += 4
            }
            
            let unmodified = CGPoint(x: x*Double(Board.blockSize), y: y*Double(Board.blockSize))
            
            switch(k) {
            case 0:
                point = CGPoint(x: x*Double(Board.blockSize), y: y*Double(Board.blockSize) + Double(Board.blockSize)); break
            case 1:
                point = CGPoint(x: x*Double(Board.blockSize), y: y*Double(Board.blockSize)); break
            case 2:
                point = CGPoint(x: x*Double(Board.blockSize) + Double(Board.blockSize), y: y*Double(Board.blockSize)); break
            case 3:
                point = CGPoint(x: x*Double(Board.blockSize) + Double(Board.blockSize), y: y*Double(Board.blockSize) + Double(Board.blockSize)); break
            default:
                point = CGPoint(x: x*Double(Board.blockSize), y: y*Double(Board.blockSize) + Double(Board.blockSize)); break
            }
            
            if(type == 4) {
                let cycle = 1.0
                var b = 0.0//time
                
                let a = Double(Int(b/cycle))*cycle
                let c = b - a
                b = c
                
                b /= cycle
                b *= 2
                b = 1 - b
                b = abs(b)
                
                let otherColor = UIColor(red: CGFloat(b), green: CGFloat(b), blue: CGFloat(b), alpha: 1.0)
                
                /*
                 let rect = SKShapeNode.init(rectOf: CGSize(width: Board.blockSize+1, height: Board.blockSize+1))
                 rect.fillColor = color
                 rect.strokeColor = color
                 rect.position = CGPoint(x: unmodified.x, y: unmodified.y)
                 
                 let tri = SKShapeNode.init(path: Board.getTrianglePath(size: Double(Board.blockSize+1), rotation: Double(Board.direction - direction)*(3.14159/2)))
                 tri.fillColor = otherColor
                 tri.strokeColor = otherColor
                 tri.position = CGPoint(x: point.x, y: point.y)*/
                
                //sprite = [RectangleLayer.init(rect: CGRect(x: unmodified.x, y: unmodified.y, width: CGFloat(Board.blockSize+1), height: CGFloat(Board.blockSize+1)), col: color.cgColor), TriangleLayer.init(col: otherColor.cgColor, corner: point, rotate: Double(Board.direction - direction)*(3.14159/2), sideLength: Double(Board.blockSize+1))]
            } else {
                let color2 = UIColor(red: CGFloat(ColorTheme.colors[Board.colorTheme][colorIndex2][0])/255.0, green: CGFloat(ColorTheme.colors[Board.colorTheme][colorIndex2][1])/255.0, blue: CGFloat(ColorTheme.colors[Board.colorTheme][colorIndex2][2])/255.0, alpha: 1.0).cgColor
                //sprite = [RectangleLayer.init(rect: CGRect(x: x*Double(Board.blockSize), y: y*Double(Board.blockSize), width: Double(Board.blockSize+1), height: Double(Board.blockSize+1)), col: color.cgColor),  TriangleLayer.init(col: color2, corner: point, rotate: Double(Board.direction - direction)*(3.14159/2), sideLength: Double(Board.blockSize)) ]
            }
        }
    }
}
