//
//  MenuButton.swift
//  coolGame
//
//  Created by Nick Seel on 2/24/17.
//  Copyright © 2017 Nick Seel. All rights reserved.
//

import Foundation
import SpriteKit

class MenuButton {
    var rect: CGRect
    var color: UIColor = UIColor.purple
    var textColor: UIColor = UIColor.black
    
    var isPressed = false
    
    var sprite = SKShapeNode()
    
    var text: SKLabelNode?
    
    init(x: Int, y: Int, width: Int, height: Int, text: String, textColor: UIColor, color: UIColor) {
        rect = CGRect.init(x: x, y: y, width: width, height: height)
        
        sprite = SKShapeNode.init(rect: rect)
        sprite.fillColor = color
        sprite.strokeColor = UIColor.clear
        let label = SKLabelNode.init(text: text)
        label.fontColor = textColor
        label.fontSize = CGFloat(height) * 0.8
        label.fontName = "Optima-Bold"
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.baseline
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        label.position = CGPoint(x: rect.midX, y: rect.midY - (label.fontSize / 4.0))
        sprite.addChild(label)
    }
    
    func update() {
        for t in InputController.currentTouches {
            if(rect.contains(t)) {
                isPressed = true
            }
        }
    }
}
