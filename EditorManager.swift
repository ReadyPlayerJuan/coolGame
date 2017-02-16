//
//  EditorManager.swift
//  coolGame
//
//  Created by Nick Seel on 2/13/17.
//  Copyright © 2017 Nick Seel. All rights reserved.
//

import Foundation
import SpriteKit

class EditorManager {
    static var drawNode: SKShapeNode!
    
    static let border = 10
    
    static var blockIconType = 0
    static let numBlockIconTypes = 2
    
    static var currentBlockIcon = SKShapeNode.init()
    static var currentBlockButton: EditorButton!
    static var rotateLeftButton: EditorButton!
    static var rotateRightButton: EditorButton!
    
    static var drawColor = -1
    static var colors = [EditorButton]()
    
    static var rotating = false
    static var menuOpen = false
    
    static var camera = CGPoint(x: 0, y: 0)
    
    class func update(delta: TimeInterval) {
        EntityManager.updateEntitySprites()
        
        if(!rotating && !menuOpen) {
            rotateLeftButton.update(delta: delta)
            rotateRightButton.update(delta: delta)
            currentBlockButton.update(delta: delta)
            for b in colors {
                b.update(delta: delta)
            }
            
            if(InputController.currentTouches.count == 1) {
                for b in colors {
                    if(b.action) {
                        drawColor = b.colorIndex
                        currentBlockIcon.fillColor = loadColor(colorIndex: drawColor)
                    }
                }
                
                if(currentBlockButton.action)  {
                    
                    blockIconType += 1
                    if(blockIconType == numBlockIconTypes) {
                        blockIconType = 0
                    }
                    
                    loadCurrentBlockIcon()
                }
                
                if(rotateLeftButton.action) {
                    GameState.hingeDirection = "left"
                    GameState.gameAction(type: "rotate")
                } else if(rotateRightButton.action) {
                    GameState.hingeDirection = "right"
                    GameState.gameAction(type: "rotate")
                }
            } else if(InputController.currentTouches.count == 2) {
                if(InputController.prevTouches.count == 2) {
                    let moveSpeed: CGFloat = 1.0 / CGFloat(Board.blockSize)
                    print(moveSpeed * ((InputController.currentTouches[0].x) - (InputController.prevTouches[0].x)))
                    camera.x += -moveSpeed * ((InputController.currentTouches[0].x) - (InputController.prevTouches[0].x))
                    camera.y -= -moveSpeed * ((InputController.currentTouches[0].y) - (InputController.prevTouches[0].y))
                }
            }
        } else if(rotating) {
            
        } else if(menuOpen) {
            
        }
        
        GameState.drawNode.position = CGPoint(x: -((camera.x + 0.5) * CGFloat(Board.blockSize)), y: ((camera.y - 0.5) * CGFloat(Board.blockSize)))
    }
    
    class func initElements() {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        let buttonSize = Int(Double(Int(width*1) - (border * 11)) / (9.0 + 1.5))
        
        for i in 0...8 {
            colors.append(EditorButton.init(x: border*(i+1) + (buttonSize*i) - Int(width / 2), y: Int(height/2) - buttonSize - border, width: buttonSize, height: buttonSize, type: 1, colorIndex: i-3))
        }
        
        for b in colors {
            for s in b.sprite {
                drawNode.addChild(s)
            }
        }
        
        currentBlockButton = EditorButton.init(x: -Int(width/2) + border, y: -Int(height/2) + border, width: Board.blockSize, height: Board.blockSize, type: 0, colorIndex: -99)
        for s in currentBlockButton.sprite {
            drawNode.addChild(s)
        }
        
        drawNode.addChild(currentBlockIcon)
        loadCurrentBlockIcon()
        
        rotateLeftButton = EditorButton.init(x: Int(width/2)-((buttonSize+border)*2), y: -Int(height/2)+border, width: buttonSize, height: buttonSize, type: 2, colorIndex: 0)
        rotateRightButton = EditorButton.init(x: Int(width/2)-(buttonSize+border), y: -Int(height/2)+border, width: buttonSize, height: buttonSize, type: 2, colorIndex: 0)
        for s in rotateLeftButton.sprite {
            drawNode.addChild(s)
        }
        for s in rotateRightButton.sprite {
            drawNode.addChild(s)
        }
    }
    
    class func loadCurrentBlockIcon() {
        currentBlockIcon.removeFromParent()
        
        switch(blockIconType) {
        case 0:
            currentBlockIcon = SKShapeNode.init(rect: CGRect.init(x: -Int(UIScreen.main.bounds.width/2) + border, y: -Int(UIScreen.main.bounds.height/2) + border, width: Board.blockSize, height: Board.blockSize))
            break
        case 1:
            currentBlockIcon = SKShapeNode.init(path: getTrianglePath(corner: CGPoint(x: -Int(UIScreen.main.bounds.width/2) + border, y: -Int(UIScreen.main.bounds.height/2) + border), rotation: 0, size: Double(Board.blockSize)))
            break
        default:
            break
        }
        
        currentBlockIcon.fillColor = loadColor(colorIndex: drawColor)
        currentBlockIcon.strokeColor = UIColor.white
        currentBlockIcon.lineWidth = 3
        currentBlockIcon.zPosition = 100
        
        drawNode.addChild(currentBlockIcon)
    }
    
    class func loadColor(colorIndex: Int) -> UIColor {
        if(colorIndex == -3) {
            return Board.backgroundColor
        } else if(colorIndex == -2) {
            return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        } else if(colorIndex == -1) {
            return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        } else if(colorIndex >= 0 && colorIndex <= 5) {
            var colorArray = ColorTheme.colors[Board.colorTheme][colorIndex]
            
            return UIColor(red: CGFloat(colorArray[0]) / 255.0, green: CGFloat(colorArray[1]) / 255.0, blue: CGFloat(colorArray[2]) / 255.0, alpha: 1.0)
        } else {
            return UIColor.clear
        }
    }
}
