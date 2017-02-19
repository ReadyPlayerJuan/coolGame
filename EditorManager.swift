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
    static var editorScene: EditorScene!
    
    static let border = 10
    
    static var blockIconType = 0
    static let numBlockIconTypes = 3
    
    static var currentBlockIcon = SKShapeNode.init()
    static var menu = SKShapeNode.init()
    static var currentBlockButton: EditorButton!
    static var rotateLeftButton: EditorButton!
    static var rotateRightButton: EditorButton!
    static var settingsButton: EditorButton!
    
    static var play: EditorButton!
    static var save: EditorButton!
    static var copyToClipboard: EditorButton!
    static var loadFromClipboard: EditorButton!
    static var reset: EditorButton!
    
    static var drawColor = -1
    static var colors = [EditorButton]()
    
    static var rotating = false
    static var inMenu = false
    
    static var singleTouchTimer = 0
    static var menuButtonTimer = 0
    static var menuButtonTimerMax = 12
    static var pressedButton = false
    
    static var camera = CGPoint(x: 0, y: 0)
    
    class func update(delta: TimeInterval) {
        EntityManager.updateEntitySprites()
        
        if(!rotating) {
            if(inMenu) {
                rotateLeftButton.update(active: false, delta: delta)
                rotateRightButton.update(active: false, delta: delta)
                currentBlockButton.update(active: false, delta: delta)
                settingsButton.update(active: false, delta: delta)
                for b in colors {
                    b.update(active: false, delta: delta)
                }
                save.update(active: true, delta: delta)
                reset.update(active: true, delta: delta)
                copyToClipboard.update(active: true, delta: delta)
                loadFromClipboard.update(active: true, delta: delta)
                play.update(active: true, delta: delta)
                
                menuButtonTimer -= 1
                if(save.action) {
                    print(encodeStageEdit())
                    Memory.saveStageEdit(code: encodeStageEdit())
                    menuButtonTimer = menuButtonTimerMax
                }
                if(reset.action) {
                    Memory.saveStageEdit(code: Stage.defaultStage)
                    inMenu = false
                    GameState.beginEditorStage()
                    menuButtonTimer = menuButtonTimerMax
                    EntityManager.reloadAllEntities()
                }
                if(copyToClipboard.action) {
                    UIPasteboard.general.string = EditorManager.encodeStageEdit()
                    copyToClipboard.sprite[1].alpha = 0.0
                }
                if(loadFromClipboard.action) {
                    let pasteboardString: String? = UIPasteboard.general.string
                    if let theString = pasteboardString {
                        Memory.saveStageEdit(code: theString)
                        inMenu = false
                        GameState.beginEditorStage()
                        menuButtonTimer = menuButtonTimerMax
                        EntityManager.reloadAllEntities()
                    }
                }
                if(play.action) {
                    Memory.saveStageEdit(code: encodeStageEdit())
                    GameState.currentlyEditing = false
                    GameState.beginGame()
                    inMenu = false
                    menuButtonTimer = menuButtonTimerMax
                    drawNode.removeAllChildren()
                    EntityManager.reloadAllEntities()
                }
                
                if(InputController.currentTouches.count > 0 && InputController.prevTouches.count == 0 && menuButtonTimer <= 0) {
                    inMenu = false
                    menu.alpha = 0.0
                    pressedButton = true
                }
            } else {
                rotateLeftButton.update(active: true, delta: delta)
                rotateRightButton.update(active: true, delta: delta)
                currentBlockButton.update(active: true, delta: delta)
                settingsButton.update(active: true, delta: delta)
                for b in colors {
                    b.update(active: true, delta: delta)
                }
                
                play.update(active: false, delta: delta)
                save.update(active: false, delta: delta)
                reset.update(active: false, delta: delta)
                copyToClipboard.update(active: false, delta: delta)
                loadFromClipboard.update(active: false, delta: delta)
                
                if(InputController.currentTouches.count == 1) {
                    if(InputController.prevTouches.count != 1) {
                        singleTouchTimer = 1
                        pressedButton = false
                    } else {
                        singleTouchTimer += 1
                    }
                } else {
                    singleTouchTimer = 0
                    pressedButton = false
                    
                    if(InputController.currentTouches.count == 2) {
                        if(InputController.prevTouches.count == 2) {
                            let moveSpeed: CGFloat = 1.0 / CGFloat(Board.blockSize)
                            camera.x += -moveSpeed * (((InputController.currentTouches[0].x) - (InputController.prevTouches[0].x)) + ((InputController.currentTouches[1].x) - (InputController.prevTouches[1].x)))/2
                            camera.y -= -moveSpeed * (((InputController.currentTouches[0].y) - (InputController.prevTouches[0].y)) + ((InputController.currentTouches[1].y) - (InputController.prevTouches[1].y)))/2
                            
                            let point0 = InputController.currentTouches[0]
                            let point1 = InputController.currentTouches[1]
                            let prevPoint0 = InputController.prevTouches[0]
                            let prevPoint1 = InputController.prevTouches[1]
                            let prevDistance = hypot(prevPoint0.x - prevPoint1.x, prevPoint0.y - prevPoint1.y)
                            let currentDistance = hypot(point0.x - point1.x, point0.y - point1.y)
                            
                            let maxSize = 150
                            let minSize = 7
                            Board.blockSize += Int((currentDistance - prevDistance) / 5.0)
                            if(Board.blockSize < minSize) {
                                Board.blockSize = minSize
                            } else if(Board.blockSize > maxSize) {
                                Board.blockSize = maxSize
                            }
                            
                            EntityManager.reloadAllEntities()
                        }
                    }
                }
                
                if(singleTouchTimer == 1 || pressedButton) {
                    for b in colors {
                        if(b.action) {
                            drawColor = b.colorIndex
                            currentBlockIcon.fillColor = loadColor(colorIndex: drawColor)
                            pressedButton = true
                        }
                    }
                    
                    if(currentBlockButton.action)  {
                        blockIconType += 1
                        if(blockIconType == numBlockIconTypes) {
                            blockIconType = 0
                        }
                        
                        loadCurrentBlockIcon()
                        pressedButton = true
                    }
                    
                    if(rotateLeftButton.action) {
                        GameState.hingeDirection = "left"
                        GameState.gameAction(type: "rotate")
                        pressedButton = true
                    } else if(rotateRightButton.action) {
                        GameState.hingeDirection = "right"
                        GameState.gameAction(type: "rotate")
                        pressedButton = true
                    }
                    
                    if(settingsButton.action) {
                        inMenu = true
                        menu.alpha = 1.0
                        menuButtonTimer = menuButtonTimerMax
                    }
                }
                
                if(GameState.state != "rotating" && singleTouchTimer > 4 && !pressedButton && !inMenu) {
                    for t in InputController.prevTouches {
                        var x = Int(camera.x + (t.x / CGFloat(Board.blockSize)) + 0.5 + 500) - 500
                        var y = Int(camera.y - (t.y / CGFloat(Board.blockSize)) + 0.5 + 500) - 500
                        
                        var addedBlock = false
                        while(x < 0) {
                            addLeftRow()
                            x += 1
                            camera.x += 1
                            addedBlock = true
                        }
                        while(x > Board.blocks[0].count-1) {
                            addRightRow()
                            addedBlock = true
                        }
                        while(y < 0) {
                            addTopRow()
                            y += 1
                            camera.y += 1
                            addedBlock = true
                        }
                        while(y > Board.blocks.count-1) {
                            addBottomRow()
                            addedBlock = true
                        }
                        
                        if(blockIconType == 0) {
                            if(drawColor == -3) {
                                Board.blocks[y][x] = Block.init(blockType: 5, color: -1, secondaryColor: -1, dir: -1, x: Double(x), y: Double(y))
                                addedBlock = true
                            } else if(drawColor == -2) {
                                Board.blocks[y][x] = Block.init(blockType: 0, color: -1, secondaryColor: -1, dir: -1, x: Double(x), y: Double(y))
                                addedBlock = true
                            } else if(drawColor == -1) {
                                Board.blocks[y][x] = Block.init(blockType: 1, color: -1, secondaryColor: -1, dir: -1, x: Double(x), y: Double(y))
                                addedBlock = true
                            } else {
                                Board.blocks[y][x] = Block.init(blockType: 2, color: drawColor, secondaryColor: -1, dir: -1, x: Double(x), y: Double(y))
                                addedBlock = true
                            }
                        } else if(blockIconType == 1) {
                            if(drawColor == -3 || drawColor == -2 || drawColor == -1) {
                                if(Board.blocks[y][x]?.type == 1 || Board.blocks[y][x]?.type == 5) {
                                    
                                } else if(Board.blocks[y][x]?.type == 0 || Board.blocks[y][x]?.type == 2 || Board.blocks[y][x]?.type == 3 || Board.blocks[y][x]?.type == 4) {
                                    Board.blocks[y][x] = Block.init(blockType: 4, color: Board.blocks[y][x]!.colorIndex, secondaryColor: -1, dir: Board.direction, x: Double(x), y: Double(y))
                                    addedBlock = true
                                }
                            } else {
                                if(Board.blocks[y][x]?.type == 1 || Board.blocks[y][x]?.type == 5) {
                                    
                                } else if(Board.blocks[y][x]?.type == 0 || Board.blocks[y][x]?.type == 2 || Board.blocks[y][x]?.type == 3 || Board.blocks[y][x]?.type == 4) {
                                    Board.blocks[y][x] = Block.init(blockType: 3, color: Board.blocks[y][x]!.colorIndex, secondaryColor: drawColor, dir: Board.direction, x: Double(x), y: Double(y))
                                    addedBlock = true
                                }
                            }
                        }
                        
                        
                        if(addedBlock) {
                            let p = EntityManager.getPlayer()!
                            EntityManager.entities = []
                            EntityManager.addEntity(entity: p)
                            
                            for row in 0 ... Board.blocks.count-1 {
                                for col in 0 ... Board.blocks[0].count-1 {
                                    Board.blocks[row][col]?.removeSpriteFromParent()
                                    EntityManager.addEntity(entity: Board.blocks[row][col]!)
                                }
                            }
                            if(Board.otherEntities.count != 0) {
                                for e in Board.otherEntities {
                                    EntityManager.addEntity(entity: e)
                                }
                            }
                            EntityManager.sortEntities()
                            EntityManager.redrawEntities(node: GameState.drawNode, name: "all")
                        }
                    }
                }
            }
        } else if(rotating) {
            rotateLeftButton.update(active: false, delta: delta)
            rotateRightButton.update(active: false, delta: delta)
            currentBlockButton.update(active: false, delta: delta)
            for b in colors {
                b.update(active: false, delta: delta)
            }
        }
        
        GameState.drawNode.position = CGPoint(x: -((camera.x + 0.5) * CGFloat(Board.blockSize)), y: ((camera.y - 0.5) * CGFloat(Board.blockSize)))
    }
    
    class func initElements() {
        drawNode.removeAllChildren()
        
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        let buttonSize = Int(Double(Int(width*1) - (border * 11)) / (9.0 + 1.5))
        
        for i in 0...8 {
            colors.append(EditorButton.init(x: border*(i+1) + (buttonSize*i) - Int(width / 2), y: Int(height/2) - buttonSize - border, width: buttonSize, height: buttonSize, leniency: border/2, type: 1, colorIndex: i-3, btext: ""))
        }
        
        for b in colors {
            for s in b.sprite {
                drawNode.addChild(s)
            }
        }
        
        currentBlockButton = EditorButton.init(x: -Int(width/2) + border, y: -Int(height/2) + border, width: Board.blockSize, height: Board.blockSize, leniency: border/2, type: 0, colorIndex: -99, btext: "")
        for s in currentBlockButton.sprite {
            drawNode.addChild(s)
        }
        
        drawNode.addChild(currentBlockIcon)
        loadCurrentBlockIcon()
        
        rotateLeftButton = EditorButton.init(x: Int(width/2)-((buttonSize+border)*2), y: -Int(height/2)+border, width: buttonSize, height: buttonSize, leniency: border/2, type: 2, colorIndex: 0, btext: "")
        rotateRightButton = EditorButton.init(x: Int(width/2)-(buttonSize+border), y: -Int(height/2)+border, width: buttonSize, height: buttonSize, leniency: border/2, type: 2, colorIndex: 1, btext: "")
        for s in rotateLeftButton.sprite {
            drawNode.addChild(s)
        }
        for s in rotateRightButton.sprite {
            drawNode.addChild(s)
        }
        
        settingsButton = EditorButton.init(x: Int(width/2)-Int(Double(buttonSize)*1.5)-border, y: Int(height/2)-border-Int(Double(buttonSize)*1.5), width: Int(Double(buttonSize)*1.5), height: Int(Double(buttonSize)*1.5), leniency: border, type: 4, colorIndex: -1, btext: "S")
        for s in settingsButton.sprite {
            drawNode.addChild(s)
        }
        
        drawNode.addChild(menu)
        menu.alpha = 0.0
        menu.zPosition = 120
        
        let screenBlur = SKShapeNode.init(rect: CGRect.init(x: -(width/2), y: -(height/2), width: width, height: height))
        screenBlur.fillColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
        screenBlur.strokeColor = UIColor.clear
        menu.addChild(screenBlur)
        
        
        let bwidth = (0.60*Double(width))
        let bheight = (0.17*Double(height))
        let numMenuItems = 5.0
        
        let temp = (Double(border)*(numMenuItems / 2.0))
        let top = temp + (bheight*((numMenuItems-2) / 2.0))
        
        var itemIndex = 0.0
        
        save = EditorButton.init(x: -Int(bwidth/2.0), y: Int(top - (itemIndex * (bheight + Double(border)))), width: Int(bwidth), height: Int(bheight), leniency: border, type: 3, colorIndex: 0, btext: "Save")
        
        itemIndex += 1
        copyToClipboard = EditorButton.init(x: -Int(bwidth/2.0), y: Int(top - (itemIndex * (bheight + Double(border)))), width: Int(bwidth), height: Int(bheight), leniency: border, type: 3, colorIndex: 0, btext: "Copy to Clipboard")
        
        itemIndex += 1
        loadFromClipboard = EditorButton.init(x: -Int(bwidth/2.0), y: Int(top - (itemIndex * (bheight + Double(border)))), width: Int(bwidth), height: Int(bheight), leniency: border, type: 3, colorIndex: 0, btext: "Load from Clipboard")
        
        itemIndex += 1
        reset = EditorButton.init(x: -Int(bwidth/2.0), y: Int(top - (itemIndex * (bheight + Double(border)))), width: Int(bwidth), height: Int(bheight), leniency: border, type: 3, colorIndex: 0, btext: "Reset")
        
        itemIndex += 1
        play = EditorButton.init(x: -Int(bwidth/2.0), y: Int(top - (itemIndex * (bheight + Double(border)))), width: Int(bwidth), height: Int(bheight), leniency: border, type: 3, colorIndex: 0, btext: "Play")
        
        for s in save.sprite {
            menu.addChild(s)
        }
        for s in copyToClipboard.sprite {
            menu.addChild(s)
        }
        for s in loadFromClipboard.sprite {
            menu.addChild(s)
        }
        for s in reset.sprite {
            menu.addChild(s)
        }
        for s in play.sprite {
            menu.addChild(s)
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
        case 2:
            currentBlockIcon = SKShapeNode.init(rect: CGRect.init(x: -Int(UIScreen.main.bounds.width/2) + border, y: -Int(UIScreen.main.bounds.height/2) + border, width: Board.blockSize, height: Board.blockSize))
            let arrow1 = SKShapeNode.init(path: getTrianglePath(corner: CGPoint(x: Double(Board.blockSize)*(1/3.0), y: Double(Board.blockSize)*((1/2.0) + (1/18.0))), rotation: 0.0, size: Double(Board.blockSize)*(1/3.0)))
            arrow1.position = CGPoint(x: -Int(UIScreen.main.bounds.width/2) + border, y: -Int(UIScreen.main.bounds.height/2) + border)
            arrow1.strokeColor = UIColor.black
            arrow1.fillColor = UIColor.clear
            arrow1.lineWidth = 2.0
            let arrow2 = SKShapeNode.init(path: getTrianglePath(corner: CGPoint(x: Double(Board.blockSize)*(2/3.0), y: Double(Board.blockSize)*((1/2.0) - (1/18.0))), rotation: 180.0, size: Double(Board.blockSize)*(1/3.0)))
            arrow2.position = CGPoint(x: -Int(UIScreen.main.bounds.width/2) + border, y: -Int(UIScreen.main.bounds.height/2) + border)
            arrow2.strokeColor = UIColor.black
            arrow2.fillColor = UIColor.clear
            arrow2.lineWidth = 2.0
            currentBlockIcon.addChild(arrow1)
            currentBlockIcon.addChild(arrow2)
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
    
    class func addLeftRow() {
        for i in 0...(Board.blocks.count - 1) {
            Board.blocks[i].insert(Block.init(blockType: 5, color: -1, secondaryColor: -1, dir: -1, x: 0, y: Double(i)), at: 0)
            for j in 1...Board.blocks[i].count-1 {
                Board.blocks[i][j]?.x += 1.0
            }
        }
        EntityManager.getPlayer()!.x += 1
        for e in Board.otherEntities {
            e.x += 1
        }
        EntityManager.reloadAllEntities()
    }
    
    class func addRightRow() {
        for i in 0...(Board.blocks.count - 1) {
            Board.blocks[i].append(Block.init(blockType: 5, color: -1, secondaryColor: -1, dir: -1, x: Double(Board.blocks[i].count), y: Double(i)))
        }
    }
    
    class func addTopRow() {
        Board.blocks.insert([Block](), at: 0)
        for _ in 0...Board.blocks[1].count-1 {
            Board.blocks[0].append(Block.init(blockType: 5, color: -1, secondaryColor: -1, dir: -1, x: 0, y: 0))
        }
        for row in 0...Board.blocks.count-1 {
            for col in 0...Board.blocks[0].count-1 {
                Board.blocks[row][col]?.y = Double(row)
                Board.blocks[row][col]?.x = Double(col)
            }
        }
        EntityManager.getPlayer()!.y += 1
        for e in Board.otherEntities {
            e.y += 1
        }
        EntityManager.reloadAllEntities()
    }
    
    class func addBottomRow() {
        Board.blocks.append([Block]())
        for i in 0...(Board.blocks[1].count - 1) {
            Board.blocks[Board.blocks.count-1].append(Block.init(blockType: 5, color: -1, secondaryColor: -1, dir: -1, x: Double(i), y: Double(Board.blocks.count-1)))
        }
    }
    
    class func encodeStageEdit() -> String {
        var code = ""
        var exits = [[Int]]()
        
        code += "b"
        for row in 0...Board.blocks.count-1 {
            for col in 0...Board.blocks[0].count-1 {
                let b = Board.blocks[row][col]!
                
                switch(b.type) {
                case 0:
                    code += "0"; break
                case 1:
                    code += "1"; break
                case 2:
                    code += "\(b.colorIndex + 2)"; break
                case 3:
                    code += "\(b.direction)\(b.colorIndex+2)\(b.colorIndex2+2)"; break
                case 4:
                    code += "-\(b.direction+1)\(b.colorIndex+2)"
                    exits.append([row, col, 0]); break
                case 5:
                    code += "-9"; break
                case 6:
                    code += "99"; break
                default:
                    break
                }
                
                if(col != Board.blocks[0].count-1) {
                    code += "."
                }
            }
            
            if(row != Board.blocks.count-1) {
                code += ","
            }
        }
        code += "e"
        
        code += "s"
        code += "\(Int(EntityManager.getPlayer()!.x))"
        code += "."
        code += "\(Int(EntityManager.getPlayer()!.y))"
        code += "e"
        
        code += "x"
        for i in 0...exits.count-1 {
            let e = exits[i]
            code += "\(e[0])"
            code += "."
            code += "\(e[1])"
            code += "."
            code += "\(e[2])"
            
            if(i != exits.count-1) {
                code += ","
            }
        }
        code += "e"
        
        code += "m"
        code += "defaultName"
        
        return code
    }
}
