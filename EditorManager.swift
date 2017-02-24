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
    
    static var iconType = 0
    static let numBlockIconTypes = 2
    static let numEntityIconTypes = 2
    
    static var switchLayerButton: EditorButton!
    static var layerNum = 0
    static var blockLayer = SKShapeNode.init()
    static var entityLayer = SKShapeNode.init()
    
    static var selectedEntity: Entity?
    static var selectedEntityFrame = SKShapeNode.init()
    
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
    
    static var exitStageButton: EditorButton!
    
    static var drawColor = -1
    static var colors = [EditorButton]()
    
    static var rotating = false
    static var inMenu = false
    
    static var prevSingleTouchTimer = 0
    static var singleTouchTimer = 0
    static var menuButtonTimer = 0
    static var menuButtonTimerMax = 12
    static var pressedButton = false
    static var prevPressedButton = false
    static var dragTimer = 0
    static var dragTimerMax = 5
    
    static var camera = CGPoint(x: 0, y: 0)
    
    class func update(delta: TimeInterval) {
        if(!GameState.currentlyEditing) {
            exitStageButton.sprite[0].position = CGPoint(x: 0, y: 0)
            exitStageButton.update(active: true, delta: delta)
            if(exitStageButton.action && GameState.state == "in game" && GameState.playerState == "free") {
                exitStageButton.sprite[0].alpha = 0.0
                GameState.gameAction(type: "begin editor")
            }
        } else {
            EntityManager.updateEntitySprites()
            
            for c in colors {
                if(c.colorIndex == -4) {
                    c.loadColor()
                    if(drawColor == -4) {
                        loadCurrentIcon()
                    }
                }
            }
            //colors[0].sprite[0].fillColor = colors[0].color
            
            if(layerNum == 0) {
                blockLayer.alpha = 1.0
                entityLayer.alpha = 0.0
            } else {
                blockLayer.alpha = 0.0
                entityLayer.alpha = 1.0
            }
            prevPressedButton = pressedButton
            prevSingleTouchTimer = singleTouchTimer
            
            if(!rotating) {
                if(inMenu) {
                    rotateLeftButton.update(active: false, delta: delta)
                    rotateRightButton.update(active: false, delta: delta)
                    currentBlockButton.update(active: false, delta: delta)
                    settingsButton.update(active: false, delta: delta)
                    
                    switchLayerButton.update(active: false, delta: delta)
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
                        Memory.saveStageEdit(code: encodeStageEdit())
                        menuButtonTimer = menuButtonTimerMax
                    }
                    if(reset.action) {
                        Memory.saveStageEdit(code: Stage.defaultStage)
                        inMenu = false
                        GameState.gameAction(type: "begin editor")
                        menuButtonTimer = menuButtonTimerMax
                        EntityManager.reloadAllEntities()
                        
                        blockLayer.alpha = 1.0
                        entityLayer.alpha = 0.0
                        selectedEntityFrame.alpha = 0.0
                        layerNum = 0
                        loadCurrentIcon()
                        //pressedButton = true
                        
                        EditorManager.camera = CGPoint(x: Double(Board.blocks[0].count-1)/2.0, y: Double(Board.blocks.count-1)/2.0)
                        GameState.drawNode.position = CGPoint(x: -((EditorManager.camera.x + 0.5) * CGFloat(Board.blockSize)), y: ((EditorManager.camera.y - 0.5) * CGFloat(Board.blockSize)))
                    }
                    if(copyToClipboard.action) {
                        UIPasteboard.general.string = EditorManager.encodeStageEdit()
                        menuButtonTimer = menuButtonTimerMax
                    }
                    if(loadFromClipboard.action) {
                        let pasteboardString: String? = UIPasteboard.general.string
                        if let theString = pasteboardString {
                            Memory.saveStageEdit(code: theString)
                            inMenu = false
                            GameState.gameAction(type: "begin editor")
                            menuButtonTimer = menuButtonTimerMax
                            EntityManager.reloadAllEntities()
                            
                            EditorManager.camera = CGPoint(x: Double(Board.blocks[0].count-1)/2.0, y: Double(Board.blocks.count-1)/2.0)
                            GameState.drawNode.position = CGPoint(x: -((EditorManager.camera.x + 0.5) * CGFloat(Board.blockSize)), y: ((EditorManager.camera.y - 0.5) * CGFloat(Board.blockSize)))
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
                        exitStageButton.sprite[0].alpha = 1.0
                    }
                    
                    if(InputController.currentTouches.count > 0 && InputController.prevTouches.count == 0 && menuButtonTimer <= 0) {
                        inMenu = false
                        menu.alpha = 0.0
                        pressedButton = true
                        menuButtonTimer = menuButtonTimerMax
                    }
                } else {
                    rotateLeftButton.update(active: true, delta: delta)
                    rotateRightButton.update(active: true, delta: delta)
                    currentBlockButton.update(active: true, delta: delta)
                    settingsButton.update(active: true, delta: delta)
                    
                    switchLayerButton.update(active: true, delta: delta)
                    for b in colors {
                        b.update(active: true, delta: delta)
                    }
                    
                    play.update(active: false, delta: delta)
                    save.update(active: false, delta: delta)
                    reset.update(active: false, delta: delta)
                    copyToClipboard.update(active: false, delta: delta)
                    loadFromClipboard.update(active: false, delta: delta)
                    
                    //check for input, pan and zoom if two touches found
                    dragTimer -= 1
                    menuButtonTimer -= 1
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
                                
                                let maxSize = 150.0
                                let minSize = 7.0
                                Board.blockSize += Double((currentDistance - prevDistance) / 5.0)
                                if(Board.blockSize < minSize) {
                                    Board.blockSize = minSize
                                } else if(Board.blockSize > maxSize) {
                                    Board.blockSize = maxSize
                                }
                                dragTimer = dragTimerMax
                                
                                selectedEntityFrame.removeFromParent()
                                selectedEntityFrame = SKShapeNode.init(rect: CGRect.init(x: -(Board.blockSize * 0.1), y: -(Board.blockSize * 0.1), width: Board.blockSize * 1.2, height: Board.blockSize * 1.2))
                                selectedEntityFrame.fillColor = UIColor.clear
                                selectedEntityFrame.strokeColor = UIColor.white
                                selectedEntityFrame.lineWidth = CGFloat(Board.blockSize / 15.0)
                                entityLayer.addChild(selectedEntityFrame)
                                
                                EntityManager.reloadAllEntities()
                            }
                        }
                    }
                    
                    //check for pressed buttons
                    if((singleTouchTimer == 1 || pressedButton) && menuButtonTimer <= 0) {
                        for b in colors {
                            if(b.action) {
                                drawColor = b.colorIndex
                                
                                if(layerNum == 1 && selectedEntity != nil && selectedEntity?.name == "moving block" && drawColor >= -1) {
                                    (selectedEntity as! MovingBlock).colorIndex = drawColor
                                    (selectedEntity as! MovingBlock).initColor()
                                    selectedEntity?.loadSprite()
                                    completeRedraw()
                                }
                                if(layerNum == 1) {
                                    loadCurrentIcon()
                                } else {
                                    currentBlockIcon.fillColor = loadColor(colorIndex: drawColor)
                                }
                                pressedButton = true
                            }
                        }
                        
                        if(currentBlockButton.action)  {
                            if(layerNum == 0) {
                                iconType += 1
                                if(iconType == numBlockIconTypes) {
                                    iconType = 0
                                }
                            } else {
                                if(drawColor >= -1) {
                                    iconType += 1
                                }
                                if(iconType == numEntityIconTypes) {
                                    iconType = 0
                                }
                            }
                            
                            if(layerNum == 1) {
                                let selectableEntities = getSelectableEntities()
                                if(layerNum == 1 && selectedEntity != nil) {
                                    for i in 0...selectableEntities.count-1 {
                                        let e = selectableEntities[i]
                                        
                                        if(e.equals(selectedEntity!) && e.name == "moving block") {
                                            let newEntity = MovingBlock.init(color: (e as! MovingBlock).colorIndex, dir: (e as! MovingBlock).direction+1, xPos: e.x, yPos: e.y)
                                            Board.otherEntities.remove(at: i)
                                            Board.otherEntities.append(newEntity)
                                            selectedEntity = newEntity
                                            completeRedraw()
                                        }
                                    }
                                }
                            }
                            
                            loadCurrentIcon()
                            pressedButton = true
                        }
                        
                        if(rotateLeftButton.action) {
                            GameState.hingeDirection = "left"
                            GameState.gameAction(type: "rotate")
                            rotating = true
                            pressedButton = true
                            if(layerNum == 1 && selectedEntity != nil) {
                                iconType += 1
                                if(iconType == 2) {
                                    iconType = 0
                                }
                            }
                            loadCurrentIcon()
                        } else if(rotateRightButton.action) {
                            GameState.hingeDirection = "right"
                            GameState.gameAction(type: "rotate")
                            rotating = true
                            pressedButton = true
                            if(layerNum == 1 && selectedEntity != nil) {
                                iconType += 1
                                if(iconType == 2) {
                                    iconType = 0
                                }
                            }
                            loadCurrentIcon()
                        }
                        
                        if(settingsButton.action) {
                            inMenu = true
                            menu.alpha = 1.0
                            menuButtonTimer = menuButtonTimerMax
                        }
                        
                        if(switchLayerButton.action) {
                            if(layerNum == 0) {
                                layerNum = 1
                                switchLayerButton.setText(newText: "E")
                                blockLayer.alpha = 0.0
                                entityLayer.alpha = 1.0
                            } else {
                                layerNum = 0
                                switchLayerButton.setText(newText: "B")
                                blockLayer.alpha = 1.0
                                entityLayer.alpha = 0.0
                            }
                            if(drawColor < -1) {
                                drawColor = -1
                            }
                            iconType = 0
                            loadCurrentIcon()
                            pressedButton = true
                        }
                    }
                    
                    if(!rotating && !pressedButton && !prevPressedButton && !inMenu && menuButtonTimer <= 0) {
                        if(layerNum == 0) {
                            if(((singleTouchTimer > 4 && dragTimer <= 0) || (prevSingleTouchTimer > 1 && singleTouchTimer == 0 && prevSingleTouchTimer <= 4 && dragTimer <= 0)) && InputController.currentTouches.count != 2 && InputController.prevTouches.count != 2) {
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
                                    
                                    drawBlock(x: x, y: y, addBlock: addedBlock)
                                }
                            }
                        } else if(layerNum == 1) {
                            
                            if(drawColor < -1) {
                                selectedEntity = nil
                                if((singleTouchTimer == 0 && prevSingleTouchTimer < 4 && InputController.prevTouches.count == 1 && InputController.currentTouches.count == 0) || (singleTouchTimer > 4 && InputController.prevTouches.count == 1 && InputController.currentTouches.count == 1))  {
                                    //quick tap
                                    let t = InputController.prevTouches[0]
                                    
                                    let x = Int(camera.x + (t.x / CGFloat(Board.blockSize)) + 0.5 + 500) - 500
                                    let y = Int(camera.y - (t.y / CGFloat(Board.blockSize)) + 0.5 + 500) - 500
                                    
                                    let selectableEntities = getSelectableEntities()
                                    for i in 0...selectableEntities.count-1 {
                                        let e = selectableEntities[i]
                                        
                                        if(e.x == Double(x) && e.y == Double(y)) {
                                            if(e.name != "player") {
                                                Board.otherEntities.remove(at: i)
                                                
                                                completeRedraw()
                                            }
                                        }
                                    }
                                }
                            } else {
                                if(selectedEntity == nil) {
                                    if((singleTouchTimer == 0 && prevSingleTouchTimer < 4 && InputController.prevTouches.count == 1 && InputController.currentTouches.count == 0) || (singleTouchTimer > 4 && InputController.prevTouches.count == 1 && InputController.currentTouches.count == 1))  {
                                        //quick tap
                                        let t = InputController.prevTouches[0]
                                        
                                        var x = Int(camera.x + (t.x / CGFloat(Board.blockSize)) + 0.5 + 500) - 500
                                        var y = Int(camera.y - (t.y / CGFloat(Board.blockSize)) + 0.5 + 500) - 500
                                        
                                        for e in getSelectableEntities() {
                                            if(e.x == Double(x) && e.y == Double(y)) {
                                                selectedEntity = e
                                                if(e.name == "moving block") {
                                                    drawColor = (e as! MovingBlock).colorIndex
                                                    if((e as! MovingBlock).direction == 0) {
                                                        iconType = 0
                                                    } else {
                                                        iconType = 1
                                                    }
                                                    loadCurrentIcon()
                                                }
                                            }
                                        }
                                        
                                        if(selectedEntity == nil) {
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
                                            
                                            drawBlock(x: x, y: y, addBlock: addedBlock)
                                        }
                                    }
                                } else {
                                    if(singleTouchTimer == 0 && InputController.prevTouches.count == 1 && prevSingleTouchTimer < 6) {
                                        //quick tap
                                        let t = InputController.prevTouches[0]
                                        
                                        let x = Int(camera.x + (t.x / CGFloat(Board.blockSize)) + 0.5 + 500) - 500
                                        let y = Int(camera.y - (t.y / CGFloat(Board.blockSize)) + 0.5 + 500) - 500
                                        
                                        var touchedEntity = false
                                        for e in getSelectableEntities() {
                                            if(e.x == Double(x) && e.y == Double(y)) {
                                                if(e.equals(selectedEntity!)) {
                                                    selectedEntity = nil
                                                } else {
                                                    selectedEntity = e
                                                    if(e.name == "moving block") {
                                                        drawColor = (e as! MovingBlock).colorIndex
                                                        if((e as! MovingBlock).direction == 0) {
                                                            iconType = 0
                                                        } else {
                                                            iconType = 1
                                                        }
                                                        loadCurrentIcon()
                                                    }
                                                }
                                                touchedEntity = true
                                            }
                                        }
                                        
                                        if(!touchedEntity) {
                                            selectedEntity = nil
                                        }
                                    } else if(singleTouchTimer > 6 && InputController.prevTouches.count == 1 && InputController.currentTouches.count == 1) {
                                        //drag
                                        let t = InputController.prevTouches[0]
                                        
                                        let x = Int(camera.x + (t.x / CGFloat(Board.blockSize)) + 0.5 + 500) - 500
                                        let y = Int(camera.y - (t.y / CGFloat(Board.blockSize)) + 0.5 + 500) - 500
                                        
                                        var newSelectedEntity: Entity? = nil
                                        for e in getSelectableEntities() {
                                            if(e.x == Double(x) && e.y == Double(y)) {
                                                newSelectedEntity = e
                                            }
                                        }
                                        
                                        if(newSelectedEntity == nil) {
                                            selectedEntity = nil
                                        } else {
                                            if(newSelectedEntity?.equals(selectedEntity!))! {
                                                let newx = Int(camera.x + (InputController.currentTouches[0].x / CGFloat(Board.blockSize)) + 0.5 + 500) - 500
                                                let newy = Int(camera.y - (InputController.currentTouches[0].y / CGFloat(Board.blockSize)) + 0.5 + 500) - 500
                                                
                                                if(!(newx == x && newy == y)) {
                                                    selectedEntity?.x = Double(newx)
                                                    selectedEntity?.y = Double(newy)
                                                    completeRedraw()
                                                }
                                            } else {
                                                selectedEntity = newSelectedEntity
                                                if(selectedEntity!.name == "moving block") {
                                                    drawColor = (selectedEntity as! MovingBlock).colorIndex
                                                    if((selectedEntity as! MovingBlock).direction == 0) {
                                                        iconType = 0
                                                    } else {
                                                        iconType = 1
                                                    }
                                                    loadCurrentIcon()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                if(layerNum == 1) {
                    if(selectedEntity == nil) {
                        selectedEntityFrame.alpha = 0.0
                    } else {
                        selectedEntityFrame.alpha = 1.0
                        selectedEntityFrame.position = CGPoint(x: (selectedEntity!.x-Double(camera.x)-0.5)*Board.blockSize, y: (-selectedEntity!.y+Double(camera.y)-0.5)*Board.blockSize)
                    }
                }
            } else if(rotating) {
                rotateLeftButton.update(active: false, delta: delta)
                rotateRightButton.update(active: false, delta: delta)
                currentBlockButton.update(active: false, delta: delta)
                for b in colors {
                    b.update(active: false, delta: delta)
                }
                
                singleTouchTimer = 0
                pressedButton = true
                
                if(layerNum == 1 && selectedEntity != nil) {
                    selectedEntityFrame.alpha = 0.0
                    selectedEntityFrame.position = CGPoint(x: (selectedEntity!.x-Double(camera.x)-0.5)*Board.blockSize, y: (-selectedEntity!.y+Double(camera.y)-0.5)*Board.blockSize)
                }
            }
            
            GameState.drawNode.position = CGPoint(x: -((camera.x + 0.5) * CGFloat(Board.blockSize)), y: ((camera.y - 0.5) * CGFloat(Board.blockSize)))
        }
    }
    
    class func getSelectableEntities() -> [Entity] {
        var temp = [Entity]()
        for e in Board.otherEntities {
            temp.append(e)
        }
        temp.append(EntityManager.getPlayer()!)
        return temp
    }
    
    class func drawBlock(x: Int, y: Int, addBlock: Bool) {
        var addedBlock = addBlock
        if(layerNum == 0) {
            if(iconType == 0) {
                if(drawColor == -4) {
                    if(Board.blocks[y][x]?.type != 6) {
                        Board.blocks[y][x] = Block.init(blockType: 6, color: -1, secondaryColor: -1, dir: -1, x: Double(x), y: Double(y))
                        addedBlock = true
                    }
                } else if(drawColor == -3) {
                    Board.blocks[y][x] = Block.init(blockType: 5, color: -1, secondaryColor: -1, dir: -1, x: Double(x), y: Double(y))
                    addedBlock = true
                } else if(drawColor == -2) {
                    if(Board.blocks[y][x]?.type != 0) {
                        Board.blocks[y][x] = Block.init(blockType: 0, color: -1, secondaryColor: -1, dir: -1, x: Double(x), y: Double(y))
                        addedBlock = true
                    }
                } else if(drawColor == -1) {
                    if(Board.blocks[y][x]?.type != 1) {
                        Board.blocks[y][x] = Block.init(blockType: 1, color: -1, secondaryColor: -1, dir: -1, x: Double(x), y: Double(y))
                        addedBlock = true
                    }
                } else {
                    if(!(Board.blocks[y][x]?.type == 2 && Board.blocks[y][x]?.colorIndex == drawColor)) {
                        Board.blocks[y][x] = Block.init(blockType: 2, color: drawColor, secondaryColor: -1, dir: -1, x: Double(x), y: Double(y))
                        addedBlock = true
                    }
                }
            } else if(iconType == 1) {
                if(drawColor == -4 || drawColor == -3 || drawColor == -2 || drawColor == -1) {
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
        } else {
            if(iconType == 0 || iconType == 1) {
                if(drawColor == -4 || drawColor == -3 || drawColor == -2) {
                    let selectableEntities = getSelectableEntities()
                    for i in 0...selectableEntities.count-1 {
                        let e = selectableEntities[i]
                        
                        if(e.x == Double(x) && e.y == Double(y)) {
                            if(e.name != "player") {
                                Board.otherEntities.remove(at: i)
                                
                                completeRedraw()
                            }
                        }
                    }
                } else if(drawColor == -1) {
                    let e = MovingBlock.init(color: -1, dir: Board.direction+iconType, xPos: Double(x), yPos: Double(y))
                    Board.otherEntities.append(e)
                    selectedEntity = e
                    addedBlock = true
                } else {
                    let e = MovingBlock.init(color: drawColor, dir: Board.direction+iconType, xPos: Double(x), yPos: Double(y))
                    Board.otherEntities.append(e)
                    selectedEntity = e
                    addedBlock = true
                }
            }
        }
            /* to be handeled in entityLayer menu
             
             var overlap = false
             for e in Board.otherEntities {
             if(e.x == Double(x) && e.y == Double(y)) {
             overlap = true
             }
             }
             if(!overlap) {
             if(drawColor == -3 || drawColor == -2 || drawColor == -1) {
             Board.otherEntities.append(MovingBlock.init(color: -1, dir: Board.direction, xPos: Double(x), yPos: Double(y)))
             EntityManager.addEntity(entity: Board.otherEntities[Board.otherEntities.count-1])
             EntityManager.sortEntities()
             EntityManager.redrawEntities(node: GameState.drawNode, name: "all")
             } else {
             Board.otherEntities.append(MovingBlock.init(color: drawColor, dir: Board.direction, xPos: Double(x), yPos: Double(y)))
             EntityManager.addEntity(entity: Board.otherEntities[Board.otherEntities.count-1])
             EntityManager.sortEntities()
             EntityManager.redrawEntities(node: GameState.drawNode, name: "all")
             }
             }*/
        
        
        if(addedBlock) {
            completeRedraw()
        }
    }
    
    class func completeRedraw() {
        let p = EntityManager.getPlayer()!
        p.loadSprite()
        EntityManager.entities = []
        EntityManager.addEntity(entity: p)
        
        for row in 0 ... Board.blocks.count-1 {
            for col in 0 ... Board.blocks[0].count-1 {
                Board.blocks[row][col]?.removeSpriteFromParent()
                EntityManager.addEntity(entity: Board.blocks[row][col]!)
            }
        }
        for row in 0 ... Board.blocks.count-1 {
            for col in 0 ... Board.blocks[0].count-1 {
                if(Board.blocks[row][col]?.type == 6) {
                    var blockPoint = CGPoint(x: col, y: row)
                    if(Board.direction > 0) {
                        for _ in 0...Board.direction-1 {
                            blockPoint = Board.rotatePoint(blockPoint, clockwise: false)
                        }
                    }
                    Board.blocks[row][col]?.colorProgressionBase = Double(blockPoint.x + blockPoint.y)
                }
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
    
    class func initElements() {
        drawNode.removeAllChildren()
        
        blockLayer = SKShapeNode.init(rect: CGRect.init(x: 0, y: 0, width: 1, height: 1))
        blockLayer.fillColor = UIColor.clear
        blockLayer.strokeColor = UIColor.clear
        drawNode.addChild(blockLayer)
        
        entityLayer = SKShapeNode.init(rect: CGRect.init(x: 0, y: 0, width: 1, height: 1))
        entityLayer.fillColor = UIColor.clear
        entityLayer.strokeColor = UIColor.clear
        drawNode.addChild(entityLayer)
        
        
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        let c = CGPoint(x: Int(width/2)-border-Int((Board.defaultBlockSize*5)/4), y: Int(height/2)-border-Int((Board.defaultBlockSize*5)/4))
        exitStageButton = EditorButton.init(x: Int(c.x), y: Int(c.y), width: Int((Board.defaultBlockSize*5)/4), height: Int((Board.defaultBlockSize*5)/4), leniency: border, type: 5, colorIndex: -1, btext: "")
        exitStageButton.sprite[0].alpha = 0.0
        for s in exitStageButton.sprite {
            editorScene.superNode.addChild(s)
        }
        
        let buttonSize = Int(Double(Int(width*1) - (border * 11)) / (10.0 + 1.5))
        
        selectedEntityFrame = SKShapeNode.init(rect: CGRect.init(x: -(Board.blockSize * 0.1), y: -(Board.blockSize * 0.1), width: Board.blockSize * 1.2, height: Board.blockSize * 1.2))
        selectedEntityFrame.fillColor = UIColor.clear
        selectedEntityFrame.strokeColor = UIColor.white
        selectedEntityFrame.lineWidth = CGFloat(Board.blockSize / 15.0)
        entityLayer.addChild(selectedEntityFrame)
        
        for i in 0...9 {
            colors.append(EditorButton.init(x: border*(i+1) + (buttonSize*i) - Int(width / 2), y: Int(height/2) - buttonSize - border, width: buttonSize, height: buttonSize, leniency: border/2, type: 1, colorIndex: i-4, btext: ""))
        }
        
        for b in colors {
            for s in b.sprite {
                drawNode.addChild(s)
            }
        }
        
        currentBlockButton = EditorButton.init(x: -Int(width/2) + border, y: -Int(height/2) + border, width: Int(Board.defaultBlockSize), height: Int(Board.defaultBlockSize), leniency: border/2, type: 0, colorIndex: -99, btext: "")
        for s in currentBlockButton.sprite {
            drawNode.addChild(s)
        }
        
        switchLayerButton = EditorButton.init(x: -Int(width/2)+border, y: -Int(height/2) + (border*2) + Int(Board.defaultBlockSize), width: Int(Board.defaultBlockSize), height: Int(Board.defaultBlockSize), leniency: border/2, type: 4, colorIndex: -1, btext: "B")
        for s in switchLayerButton.sprite {
            drawNode.addChild(s)
        }
        
        drawNode.addChild(currentBlockIcon)
        loadCurrentIcon()
        
        
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
        let bheight = (0.14*Double(height))
        let numMenuItems = 5.0
        
        let temp = (Double(border)*(numMenuItems / 2.0))
        let top = temp + (bheight*((numMenuItems-2) / 2.0))
        
        var itemIndex = 0.0
        
        save = EditorButton.init(x: -Int(bwidth/2.0), y: Int(top - (itemIndex * (bheight + Double(border)))), width: Int(bwidth), height: Int(bheight), leniency: border, type: 3, colorIndex: 0, btext: "Save")
        
        itemIndex += 1
        copyToClipboard = EditorButton.init(x: -Int(bwidth/2.0), y: Int(top - (itemIndex * (bheight + Double(border)))), width: Int(bwidth), height: Int(bheight), leniency: border, type: 3, colorIndex: 0, btext: "Copy to Clipboard")
        
        itemIndex += 1
        loadFromClipboard = EditorButton.init(x: -Int(bwidth/2.0), y: Int(top - (itemIndex * (bheight + Double(border)))), width: Int(bwidth), height: Int(bheight), leniency: border, type: 3, colorIndex: 0, btext: "Load from Clipboard")
        loadFromClipboard.sprite[1].position = CGPoint(x: -9999, y: -9999)
        
        itemIndex += 1
        reset = EditorButton.init(x: -Int(bwidth/2.0), y: Int(top - (itemIndex * (bheight + Double(border)))), width: Int(bwidth), height: Int(bheight), leniency: border, type: 3, colorIndex: 0, btext: "Reset")
        reset.sprite[1].position = CGPoint(x: -9999, y: -9999)
        
        itemIndex += 1
        play = EditorButton.init(x: -Int(bwidth/2.0), y: Int(top - (itemIndex * (bheight + Double(border)))), width: Int(bwidth), height: Int(bheight), leniency: border, type: 3, colorIndex: 0, btext: "Play")
        play.sprite[1].position = CGPoint(x: -9999, y: -9999)
        
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
    
    class func loadCurrentIcon() {
        currentBlockIcon.removeFromParent()
        
        if(layerNum == 0) {
            switch(iconType) {
            case 0:
                currentBlockIcon = SKShapeNode.init(rect: CGRect.init(x: -Int(UIScreen.main.bounds.width/2) + border, y: -Int(UIScreen.main.bounds.height/2) + border, width: Int(Board.defaultBlockSize), height: Int(Board.defaultBlockSize)))
                break
            case 1:
                currentBlockIcon = SKShapeNode.init(path: getTrianglePath(corner: CGPoint(x: -Int(UIScreen.main.bounds.width/2) + border, y: -Int(UIScreen.main.bounds.height/2) + border), rotation: 0, size: Double(Board.defaultBlockSize)))
                break
            default:
                break
            }
        } else if(layerNum == 1) {
            if(drawColor < -1) {
                let path1 = UIBezierPath.init()
                let size = 0.08
                path1.move(to: CGPoint(x: 0, y: Double(Board.defaultBlockSize)*size))
                path1.addLine(to: CGPoint(x: Double(Board.defaultBlockSize)*size, y: 0))
                path1.addLine(to: CGPoint(x: Double(Board.defaultBlockSize)*(1), y: Double(Board.defaultBlockSize)*(1-size)))
                path1.addLine(to: CGPoint(x: Double(Board.defaultBlockSize)*(1-size), y: Double(Board.defaultBlockSize)*(1)))
                
                let line1 = SKShapeNode.init(path: path1.cgPath)
                line1.fillColor = UIColor.red
                line1.strokeColor = UIColor.clear
                line1.zPosition = 50
                
                let path2 = UIBezierPath.init()
                path2.move(to: CGPoint(x: Double(Board.defaultBlockSize), y: Double(Board.defaultBlockSize)*size))
                path2.addLine(to: CGPoint(x: Double(Board.defaultBlockSize)*(1-size), y: 0))
                path2.addLine(to: CGPoint(x: Double(Board.defaultBlockSize)*(0), y: Double(Board.defaultBlockSize)*(1-size)))
                path2.addLine(to: CGPoint(x: Double(Board.defaultBlockSize)*(size), y: Double(Board.defaultBlockSize)*(1)))
                
                let line2 = SKShapeNode.init(path: path2.cgPath)
                line2.fillColor = UIColor.red
                line2.strokeColor = UIColor.clear
                
                line1.position = CGPoint(x: -Int(UIScreen.main.bounds.width/2) + border, y: -Int(UIScreen.main.bounds.height/2) + border)
                currentBlockIcon = line1
                line1.addChild(line2)
                currentBlockIcon.zPosition = 100
            } else {
                switch(iconType) {
                case 0:
                    currentBlockIcon = SKShapeNode.init(rect: CGRect.init(x: -Int(UIScreen.main.bounds.width/2) + border, y: -Int(UIScreen.main.bounds.height/2) + border, width: Int(Board.defaultBlockSize), height: Int(Board.defaultBlockSize)))
                    let arrow1 = SKShapeNode.init(path: getTrianglePath(corner: CGPoint(x: Double(Board.defaultBlockSize)*(1/3.0), y: Double(Board.defaultBlockSize)*((1/2.0) + (1/18.0))), rotation: 0.0, size: Double(Board.defaultBlockSize)*(1/3.0)))
                    arrow1.position = CGPoint(x: -Int(UIScreen.main.bounds.width/2) + border, y: -Int(UIScreen.main.bounds.height/2) + border)
                    arrow1.strokeColor = UIColor.black
                    arrow1.fillColor = UIColor.clear
                    arrow1.lineWidth = 2.0
                    let arrow2 = SKShapeNode.init(path: getTrianglePath(corner: CGPoint(x: Double(Board.defaultBlockSize)*(2/3.0), y: Double(Board.defaultBlockSize)*((1/2.0) - (1/18.0))), rotation: 180.0, size: Double(Board.defaultBlockSize)*(1/3.0)))
                    arrow2.position = CGPoint(x: -Int(UIScreen.main.bounds.width/2) + border, y: -Int(UIScreen.main.bounds.height/2) + border)
                    arrow2.strokeColor = UIColor.black
                    arrow2.fillColor = UIColor.clear
                    arrow2.lineWidth = 2.0
                    currentBlockIcon.addChild(arrow1)
                    currentBlockIcon.addChild(arrow2)
                    break
                case 1:
                    currentBlockIcon = SKShapeNode.init(rect: CGRect.init(x: -Int(UIScreen.main.bounds.width/2) + border, y: -Int(UIScreen.main.bounds.height/2) + border, width: Int(Board.defaultBlockSize), height: Int(Board.defaultBlockSize)))
                    let arrow1 = SKShapeNode.init(path: getTrianglePath(corner: CGPoint(x: Double(Board.defaultBlockSize)*((1/2.0) - (1/18.0)), y: Double(Board.defaultBlockSize)*(1/3.0)), rotation: 90.0, size: Double(Board.defaultBlockSize)*(1/3.0)))
                    arrow1.position = CGPoint(x: -Int(UIScreen.main.bounds.width/2) + border, y: -Int(UIScreen.main.bounds.height/2) + border)
                    arrow1.strokeColor = UIColor.black
                    arrow1.fillColor = UIColor.clear
                    arrow1.lineWidth = 2.0
                    let arrow2 = SKShapeNode.init(path: getTrianglePath(corner: CGPoint(x: Double(Board.defaultBlockSize)*((1/2.0) + (1/18.0)), y: Double(Board.defaultBlockSize)*(2/3.0)), rotation: -90.0, size: Double(Board.defaultBlockSize)*(1/3.0)))
                    arrow2.position = CGPoint(x: -Int(UIScreen.main.bounds.width/2) + border, y: -Int(UIScreen.main.bounds.height/2) + border)
                    arrow2.strokeColor = UIColor.black
                    arrow2.fillColor = UIColor.clear
                    arrow2.lineWidth = 2.0
                    currentBlockIcon.addChild(arrow1)
                    currentBlockIcon.addChild(arrow2)
                    break
                default:
                    break
                }
            }
        }
        
        if(!(layerNum == 1 && drawColor < -1)) {
            currentBlockIcon.fillColor = loadColor(colorIndex: drawColor)
            currentBlockIcon.strokeColor = UIColor.white
            currentBlockIcon.lineWidth = 3
            currentBlockIcon.zPosition = 100
        }
        if(layerNum == 0 && iconType == 0 && drawColor == -4) {
            for c in colors {
                if(c.colorIndex == -4) {
                    currentBlockIcon.fillColor = c.color
                }
            }
        }
        
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
                if(Board.blocks[i][j]?.type == 6) {
                    Board.blocks[i][j]?.colorProgressionBase += 1
                }
            }
        }
        Board.spawnPoint.x += 1
        EntityManager.getPlayer()!.x += 1
        for e in Board.otherEntities {
            e.x += 1
        }
        EntityManager.reloadAllEntities()
    }
    
    class func trimLeftRow() {
        for i in 0...Board.blocks.count-1 {
            Board.blocks[i].remove(at: 0)
            for j in 0...Board.blocks[i].count-1 {
                Board.blocks[i][j]?.x -= 1.0
            }
        }
        Board.spawnPoint.x -= 1
        EntityManager.getPlayer()!.x -= 1
        for e in Board.otherEntities {
            e.x -= 1
        }
        EntityManager.reloadAllEntities()
    }
    
    class func addRightRow() {
        for i in 0...(Board.blocks.count - 1) {
            Board.blocks[i].append(Block.init(blockType: 5, color: -1, secondaryColor: -1, dir: -1, x: Double(Board.blocks[i].count), y: Double(i)))
        }
    }
    
    class func trimRightRow() {
        for i in 0...(Board.blocks.count - 1) {
            Board.blocks[i].remove(at: Board.blocks[i].count-1)
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
        Board.spawnPoint.y += 1
        EntityManager.getPlayer()!.y += 1
        for e in Board.otherEntities {
            e.y += 1
        }
        EntityManager.reloadAllEntities()
    }
    
    class func trimTopRow() {
        Board.blocks.remove(at: 0)
        for row in 0...Board.blocks.count-1 {
            for col in 0...Board.blocks[0].count-1 {
                Board.blocks[row][col]?.y = Double(row)
                Board.blocks[row][col]?.x = Double(col)
            }
        }
        Board.spawnPoint.y -= 1
        EntityManager.getPlayer()!.y -= 1
        for e in Board.otherEntities {
            e.y -= 1
        }
        EntityManager.reloadAllEntities()
    }
    
    class func addBottomRow() {
        Board.blocks.append([Block]())
        for i in 0...(Board.blocks[1].count - 1) {
            Board.blocks[Board.blocks.count-1].append(Block.init(blockType: 5, color: -1, secondaryColor: -1, dir: -1, x: Double(i), y: Double(Board.blocks.count-1)))
        }
    }
    
    class func trimBottomRow() {
        Board.blocks.remove(at: Board.blocks.count-1)
    }
    
    class func trim() {
        var trimmable: Bool
        
        trimmable = true
        while(trimmable) {
            trimmable = true
            for row in 0...Board.blocks.count-1 {
                if(Board.blocks[row][0]?.type != 5) {
                    trimmable = false
                }
            }
            if(trimmable) {
                trimLeftRow()
                camera.x -= 1
            }
        }
        
        trimmable = true
        while(trimmable) {
            trimmable = true
            for row in 0...Board.blocks.count-1 {
                if(Board.blocks[row][Board.blocks[0].count-1]?.type != 5) {
                    trimmable = false
                }
            }
            if(trimmable) {
                trimRightRow()
            }
        }
        
        trimmable = true
        while(trimmable) {
            trimmable = true
            for col in 0...Board.blocks[0].count-1 {
                if(Board.blocks[0][col]?.type != 5) {
                    trimmable = false
                }
            }
            if(trimmable) {
                trimTopRow()
                camera.y -= 1
            }
        }
        
        trimmable = true
        while(trimmable) {
            trimmable = true
            for col in 0...Board.blocks[0].count-1 {
                if(Board.blocks[Board.blocks.count-1][col]?.type != 5) {
                    trimmable = false
                }
            }
            if(trimmable) {
                trimBottomRow()
            }
        }
        
        completeRedraw()
    }
    
    class func encodeStageEdit() -> String {
        trim()
        
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
                    var d = b.direction-Board.direction + 8
                    d %= 4
                    code += "\(d)\(b.colorIndex+2)\(b.colorIndex2+2)"; break
                case 4:
                    var d = b.direction+1-Board.direction + 8
                    d %= 4
                    code += "-\(d)\(b.colorIndex+2)"
                    exits.append([col, row, 0]); break
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
        if(exits.count == 0) {
            code += "0.0.0"
        } else {
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
        }
        code += "e"
        
        for e in Board.otherEntities {
            code += "n"
            
            if(e.name == "moving block") {
                code += "0"
                code += "\((e as! MovingBlock).colorIndex)"
                code += "."
                code += "\((e as! MovingBlock).direction)"
                code += "."
                code += "\(Int(e.x))"
                code += "."
                code += "\(Int(e.y))"
                code += "e"
            } else {
                
            }
        }
        
        code += "m"
        code += "defaultName"
        
        return code
    }
}
