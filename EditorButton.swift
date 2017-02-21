//
//  Button.swift
//  coolGame
//
//  Created by Nick Seel on 2/13/17.
//  Copyright © 2017 Nick Seel. All rights reserved.
//

import Foundation
import SpriteKit

class EditorButton {
    var rect: CGRect
    var buttonRect: CGRect
    var colorIndex: Int
    var color: UIColor = UIColor.purple
    var type: Int
    
    var pressTimer: Double = 0.0
    var pressTimerMax = 0.3
    
    var isPressed = false
    var prevPressed = false
    var action = false
    
    var darkSquare = [SKShapeNode]()
    var sprite = [SKShapeNode]()
    
    var text: SKLabelNode?
    
    init(x: Int, y: Int, width: Int, height: Int, leniency: Int, type: Int, colorIndex: Int, btext: String) {
        rect = CGRect.init(x: x, y: y, width: width, height: height)
        buttonRect = CGRect.init(x: x-leniency, y: y-leniency, width: width+(leniency*2), height: height+(leniency*2))
        self.colorIndex = colorIndex
        self.type = type
        loadColor()
        
        switch(type) {
        case 0:
            sprite = [SKShapeNode.init(), SKShapeNode.init(rect: rect)]
            sprite[0].fillColor = UIColor.clear
            sprite[0].strokeColor = UIColor.clear
            break
        case 1:
            sprite = [SKShapeNode.init(rect: rect), SKShapeNode.init(rect: rect)]
            sprite[0].fillColor = color
            sprite[0].strokeColor = UIColor.white
            sprite[0].lineWidth = 3
            sprite[0].zPosition = 101
            break
        case 2:
            let gray = CGFloat(0.6)
            let gray2 = CGFloat(0.2)
            color = UIColor.init(red: gray, green: gray, blue: gray, alpha: 1.0)
            let color2 = UIColor.init(red: gray2, green: gray2, blue: gray2, alpha: 1.0)
            sprite = [SKShapeNode.init(rect: rect), SKShapeNode.init(rect: rect)]
            sprite[0].fillColor = color//UIColor.init(red: gray, green: gray, blue: gray, alpha: 1.0)
            sprite[0].strokeColor = color2
            sprite[0].lineWidth = 3
            sprite[0].zPosition = 101
            if(colorIndex == 0) {
                let s = 0.6
                let vs = 0.15
                let offset = 0.05
                let arrowBody = SKShapeNode.init(rect: CGRect.init(x: (Double(width) * (0.5 + offset)) - ((s/2) * Double(width)), y: (Double(height) * (0.5)) - ((vs/2) * Double(height)), width: s*Double(width), height: vs*Double(height)))
                arrowBody.position = CGPoint(x: x, y: y)
                arrowBody.fillColor = color2
                arrowBody.strokeColor = UIColor.clear
                arrowBody.zPosition = 2
                let arrowHead = SKShapeNode.init(path: getTrianglePath(corner: CGPoint.init(x: Double(width)*((s / -2.0) + 0.47 - offset), y: Double(height)/2.0), rotation: 330, size: Double(height)*vs*2.5))
                arrowHead.position = CGPoint(x: x, y: y)
                arrowHead.fillColor = color2
                arrowHead.strokeColor = UIColor.clear
                arrowHead.zPosition = 2
                sprite[0].addChild(arrowBody)
                sprite[0].addChild(arrowHead)
            } else if(colorIndex == 1) {
                let s = 0.6
                let vs = 0.15
                let offset = 0.05
                let arrowBody = SKShapeNode.init(rect: CGRect.init(x: (Double(width) * (0.5 - offset)) - ((s/2) * Double(width)), y: (Double(height) * (0.5)) - ((vs/2) * Double(height)), width: s*Double(width), height: vs*Double(height)))
                arrowBody.position = CGPoint(x: x, y: y)
                arrowBody.fillColor = color2
                arrowBody.strokeColor = UIColor.clear
                arrowBody.zPosition = 2
                let arrowHead = SKShapeNode.init(path: getTrianglePath(corner: CGPoint.init(x: (Double(width)*((s/2.0) + 0.53 + offset)), y: Double(height)/2.0), rotation: 150, size: Double(height)*vs*2.5))
                arrowHead.position = CGPoint(x: x, y: y)
                arrowHead.fillColor = color2
                arrowHead.strokeColor = UIColor.clear
                arrowHead.zPosition = 2
                sprite[0].addChild(arrowBody)
                sprite[0].addChild(arrowHead)
            }
            break
        case 3:
            let gray = CGFloat(0.6)
            let gray2 = CGFloat(0.2)
            color = UIColor.init(red: gray, green: gray, blue: gray, alpha: 1.0)
            let color2 = UIColor.init(red: gray2, green: gray2, blue: gray2, alpha: 1.0)
            sprite = [SKShapeNode.init(rect: rect), SKShapeNode.init(rect: rect)]
            //sprite[1].position = CGPoint(x: -9999, y: -9999)
            sprite[0].fillColor = color
            sprite[0].strokeColor = color2
            sprite[0].lineWidth = 3
            sprite[0].zPosition = 101
            sprite[0].zPosition = 101
            text = SKLabelNode.init(text: btext)
            text?.fontName = "Optima-Bold"
            text?.fontSize = rect.height * 0.8
            text?.position = CGPoint(x: rect.midX, y: rect.midY)
            text?.fontColor = UIColor.black
            text?.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
            text?.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
            text?.zPosition = 3
            sprite[0].addChild(text!)
            break
        case 4:
            let gray = CGFloat(0.6)
            color = UIColor.init(red: gray, green: gray, blue: gray, alpha: 1.0)
            sprite = [SKShapeNode.init(rect: rect), SKShapeNode.init(rect: rect)]
            //sprite[1].position = CGPoint(x: -9999, y: -9999)
            sprite[0].fillColor = color
            sprite[0].strokeColor = UIColor.white
            sprite[0].lineWidth = 3
            text = SKLabelNode.init(text: btext)
            text?.fontName = "Optima-Bold"
            text?.fontSize = rect.height * 1.0
            text?.position = CGPoint(x: rect.midX, y: rect.midY)
            text?.fontColor = UIColor.white
            text?.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
            text?.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
            text?.zPosition = 3
            sprite[0].addChild(text!)
            break
        default:
            break
        }
        
        sprite[1].fillColor = UIColor.black
        sprite[1].strokeColor = UIColor.black
        sprite[1].alpha = 0.0
        sprite[1].zPosition = 110
    }
    
    func setText(newText: String) {
        if(type == 3 || type == 4) {
            (sprite[0].children[0] as! SKLabelNode).text = newText
        } else {
            print("cannot change button text")
        }
    }
    
    func update(active: Bool, delta: TimeInterval) {
        prevPressed = isPressed
        isPressed = false
        action = false
        
        sprite[1].alpha = 0.0
        for t in InputController.currentTouches {
            if(buttonRect.contains(t) && GameState.state != "rotating" && active) {
                isPressed = true
            }
        }
        if(isPressed && !prevPressed && pressTimer == 0) {
            pressTimer = pressTimerMax
            action = true
            if(type != 0) {
                sprite[1].alpha = 1.0
            }
        } else {
            if(pressTimer > 0) {
                pressTimer -= delta
                
                if(pressTimer <= 0) {
                    pressTimer = 0.0
                }
                if(type != 0) {
                    sprite[1].alpha = CGFloat(pressTimer / pressTimerMax)
                }
            }
        }
    }
    
    func loadColor() {
        if(colorIndex == -3) {
            color = Board.backgroundColor
        } else if(colorIndex == -2) {
            color = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        } else if(colorIndex == -1) {
            color = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        } else if(colorIndex >= 0 && colorIndex <= 5) {
            var colorArray = ColorTheme.colors[Board.colorTheme][colorIndex]
            
            color = UIColor(red: CGFloat(colorArray[0]) / 255.0, green: CGFloat(colorArray[1]) / 255.0, blue: CGFloat(colorArray[2]) / 255.0, alpha: 1.0)
        } else {
            color = UIColor.clear
        }
    }
}
