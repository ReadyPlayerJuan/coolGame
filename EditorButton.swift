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
    
    init(x: Int, y: Int, width: Int, height: Int, type: Int, colorIndex: Int) {
        rect = CGRect.init(x: x, y: y, width: width, height: height)
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
            color = UIColor.init(red: gray, green: gray, blue: gray, alpha: 1.0)
            sprite = [SKShapeNode.init(rect: rect), SKShapeNode.init(rect: rect)]
            sprite[0].fillColor = color//UIColor.init(red: gray, green: gray, blue: gray, alpha: 1.0)
            sprite[0].strokeColor = UIColor.white
            sprite[0].lineWidth = 3
            sprite[0].zPosition = 101
            break
        default:
            break
        }
        
        sprite[1].fillColor = UIColor.black
        sprite[1].strokeColor = UIColor.black
        sprite[1].alpha = 0.0
        sprite[1].zPosition = 102
    }
    
    func update(delta: TimeInterval) {
        prevPressed = isPressed
        isPressed = false
        action = false
        
        for t in InputController.currentTouches {
            if(rect.contains(t)) {
                isPressed = true
            }
        }
        if(isPressed && !prevPressed && pressTimer == 0) {
            pressTimer = pressTimerMax
            action = true
        }
        
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
