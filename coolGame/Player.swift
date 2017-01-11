//
//  Player.swift
//  Drawing Test
//
//  Created by Erin Seel on 11/25/16.
//  Copyright © 2016 Nick Seel. All rights reserved.
//

import Foundation
import GameplayKit

class Player: Entity {
    var rotation = 0.0
    var rotationVel = 0.0
    
    var gravitySpeed = 45.0
    var speed = 2.0
    var slide = 0.6
    
    let colAcc = 0.0001
    
    var movingRight = false
    var movingLeft = false
    var jumping = false
    var canHingeLeft = false
    var canHingeRight = false
    
    var colorIndex = -1
    var newColorIndex = -1
    var color: UIColor!
    var newColor: UIColor?
    
    override init() {
        super.init()
        
        collisionType = 0
        collidesWithType = [0, 10, 11, 12, 13, 14, 15]
        collisionPriority = -1
        drawPriority = 99
        controllable = true
        isDynamic = true
        name = "player"
        
        reset()
        
        loadSprite()
    }
    
    func reset() {
        x = Double(Board.spawnPoint.x)
        y = Double(Board.spawnPoint.y)
        xVel = 0.0
        //nxVel = 0.0
        yVel = 0.0
        
        colorIndex = -1
        color = loadColor(colIndex: colorIndex)
        newColor = loadColor(colIndex: newColorIndex)
    }
    
    override func loadSprite() {
        for each in sprite {
            each.removeFromParent()
        }
        let temp = SKShapeNode.init(path: getTrianglePath(corner: CGPoint(x: 0, y: 0), rotation: 0.0, size: Double(Board.blockSize)))
        temp.fillColor = color
        temp.strokeColor = UIColor.clear
        temp.position = CGPoint(x: x * Double(Board.blockSize), y: -y * Double(Board.blockSize))
        
        sprite = [temp]
    }
    
    override func updateSprite() {
        if(GameState.playerState == "free") {
            sprite[0].position = CGPoint(x: x * Double(Board.blockSize), y: -y * Double(Board.blockSize))
            sprite[0].zRotation = 0.0
        } else if(GameState.playerState == "rotating") {
            if(GameState.hingeDirection == "left") {
                let pi = 3.14159265
                var rotationRad = (rotation * 2 * pi) / 360.0
                
                if(GameState.begunRotation) {
                    rotationRad = (30 * 2 * pi) / 360.0
                }
                
                sprite[0].zRotation = CGFloat(rotationRad)
                sprite[0].position = CGPoint(x: x * Double(Board.blockSize), y: -y * Double(Board.blockSize))
            } else {
                let pi = 3.14159265
                var rotationRad = (rotation * 2 * pi) / 360.0
                
                if(GameState.begunRotation) {
                    rotationRad = (-30 * 2 * pi) / 360.0
                }
                
                sprite[0].zRotation = CGFloat(rotationRad)
                sprite[0].position = CGPoint(x: (x + (1 - cos(rotationRad))) * Double(Board.blockSize), y: -(y + sin(rotationRad)) * Double(Board.blockSize))
            }
        } else if(GameState.playerState == "changing color") {
            sprite[0].position = CGPoint(x: x * Double(Board.blockSize), y: -y * Double(Board.blockSize))
            sprite[0].zRotation = 0.0
            
            updateColorEffect()
        }
    }
    
    func loadColorEffect() {
        sprite[0].removeAllChildren()
        
        let pattern = loadRandomEffectPattern()
        let numTriangles = (pattern.count+1)/2
        
        let size = (Double(Board.blockSize) / Double(numTriangles)) + 0.0
        
        let diff = 0.1
        let s = SKShapeNode.init(path: getTrianglePath(corner: CGPoint(x: -diff, y: -0.0), rotation: 0.0, size: size + 2*diff))
        s.strokeColor = UIColor.clear
        s.fillColor = newColor!
        
        for ty in stride(from: 0, to: numTriangles, by: 1) {
            s.zRotation = 0.0
            for tx in stride(from: 0, to: numTriangles-ty, by: 1) {
                s.position = CGPoint(x: (Double(tx) + Double(ty)/2.0)*size, y: Double(ty)*size*(sqrt(3.0)/2.0))
                s.name = pattern[(2*(numTriangles-ty))-2][tx]
                sprite[0].addChild(s.copy() as! SKShapeNode)
            }
            s.zRotation = (3.14159265358979 / 3.0)
            for tx in stride(from: 0, to: numTriangles-ty-1, by: 1) {
                s.position = CGPoint(x: (Double(tx+1) + Double(ty)/2.0)*size, y: Double(ty)*size*(sqrt(3.0)/2.0))
                s.name = (pattern[(2*(numTriangles-ty))-3][tx])
                sprite[0].addChild(s.copy() as! SKShapeNode)
            }
        }
    }
    
    func loadRandomEffectPattern() -> [[String]] {
        var code: String!
        
        let numCodes = 3.0
        switch(Int(rand()*numCodes)) {
        case 0:
            code = //"e5abhln5bchln3gkm5ceino3fil3dfj3ehka3ehk3dfja3fil5ceinoaa3gkm5bchln3fil3dfj5bchln5abhln3gkm3ehk5ceino5abhln"
                   //"gabdcedgfehgfjihgkjihmlkjinmlkjponmlkqponmlsrqponm"
                   "gytsqwxkmsgpolqmujnircfexvdnjulgfhiotbcdhkraebpwyv"
            break
        case 1:
            code = //"eeideihcdeihgbcdeihgfabcde"
                   //"da5bdehi5cefij3dghkk3dgh3acj5defij5bdehik5bdehia5cefij3dgha"
                   "da3bdf3cei3egi3dfj3dfj3egia3cei3bdf3dfj3bdfa3cei3egia"
            break
        case 2:
            code = "iakkkyyyyyypqyppqyogqxoghrxnahrxnfbirwmecisawmdjsakwlkjskkkvlktkkyyvuutyyyyyvutyyy"
            break
        default:
            code = "dabccddcecbdbacca"
            break
        }
        
        return decodeEffectPattern(code: code)
    }
    
    func decodeEffectPattern(code: String) -> [[String]] {
        var pattern: [[String]] = [[]]
        for _ in 0...(2*numberFromLetter(code.charAt(0)))-1 {
            pattern.append([])
        }
        var currentPatternRow = 0
        
        var index = 1
        while(index <= code.characters.count-1) {
            let current = code.charAt(index)
            var cell = ""
            
            if(numberFromLetter(current) == -1) {
                //current is not a letter
                for _ in 0...current.toInt()-1 {
                    index += 1
                    cell = "\(cell)\(code.charAt(index))"
                }
            } else {
                cell = current
            }
            
            pattern[currentPatternRow].append(cell)
            if(pattern[currentPatternRow].count > Int(Double(currentPatternRow) / 2.0)) {
                currentPatternRow += 1
            }
            
            index += 1
        }
        
        return pattern
    }
    
    func updateColorEffect() {
        var max = 0
        for tri in sprite[0].children {
            for index in 0...(tri.name!.characters.count)-1 {
                let number = numberFromLetter(tri.name!.charAt(index))
                if(number > max) {
                    max = number
                }
            }
        }
        max += 1
        
        let timerValue = (1.0 - (GameState.colorChangeTimer / GameState.colorChangeTimerMax)) * Double(max)
        for tri in sprite[0].children {
            var passedTime = Double(max)
            var passedTimeIndex = 0
            
            for index in 0...(tri.name!.characters.count)-1 {
                let number = Double(numberFromLetter(tri.name!.charAt(index)))
                
                if(timerValue >= number) {
                    passedTime = number
                    passedTimeIndex = index
                }
            }
            
            var a = timerValue - Double(passedTime)
            if(a < 0) {
                a = 0.0
            } else if(a > 1) {
                a = 1.0
            }
            if(passedTimeIndex%2 == 1) {
                a = 1-a
            }
            
            tri.alpha = CGFloat(a)
        }
    }
    
    func numberFromLetter(_ char: String) -> Int {
        let chars = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
        for i in 0...25 {
            if(char == chars[i]) {
                return i
            }
        }
        return -1
    }
    
    func loadColor(colIndex: Int) -> UIColor {
        if(colIndex == -1) {
            let blockVariation = rand()*Double(Board.colorVariation)
            
            let c = UIColor(red: 1.0-(CGFloat(blockVariation)/255.0), green: 1.0-(CGFloat(blockVariation)/255.0), blue: 1.0-(CGFloat(blockVariation)/255.0), alpha: 1.0)
            return c
        } else {
            let blockVariation = (Board.colorVariation/2.0) - (rand()*Board.colorVariation)
            var colorArray = ColorTheme.colors[Board.colorTheme][colIndex]
            
            for index in 0 ... 2 {
                colorArray[index] = max(min(colorArray[index] + Int(blockVariation), 255), 0)
            }
            
            let c = UIColor(red: CGFloat(colorArray[0]) / 255.0, green: CGFloat(colorArray[1]) / 255.0, blue: CGFloat(colorArray[2]) / 255.0, alpha: 1.0)
            return c
        }
    }
    
    func move(delta: Double) {
        if(jumping) {
            //check if able to jump
            if(y == Double(Int(y)) && yVel == 0) {
                yVel = -0.22
            }
        }
        if(movingLeft) {
            xVel -= GameState.moveSpeed * delta
        }
        if(movingRight) {
            xVel += GameState.moveSpeed * delta
        }
        
        yVel += GameState.gravity * delta
        xVel *= 0.56
        
        super.update(delta: delta)
    }
    
    func rotate(delta: Double) {
        let rotateSpeed = 2.5
        
        if(movingLeft) {
            rotationVel += rotateSpeed * 3 * delta
        }
        if(movingRight) {
            rotationVel -= rotateSpeed * 3 * delta
        }
        
        if(GameState.hingeDirection == "left") {
            rotationVel -= rotateSpeed * delta
        } else {
            rotationVel += rotateSpeed * delta
        }
        
        rotation += rotationVel
        
        if(GameState.hingeDirection == "left") {
            if(rotation >= 30) {
                rotation = 0.0
                rotationVel = 0.0
                //GameState.playerState = "free"
                GameState.beginRotation()
            } else if(rotation < 0) {
                rotation = 0.0
                rotationVel = 0.0
                GameState.playerState = "free"
            }
        } else {
            if(rotation <= -30) {
                rotation = 0.0
                rotationVel = 0.0
                //GameState.playerState = "free"
                GameState.beginRotation()
            } else if(rotation > 0) {
                rotation = 0.0
                rotationVel = 0.0
                GameState.playerState = "free"
            }
        }
    }
    
    override func update(delta: TimeInterval) {
        if(GameState.state == "in game") {
            checkInputForMovement()
            
            if(GameState.playerState == "free") {
                move(delta: delta)
            } else if(GameState.playerState == "rotating") {
                rotate(delta: delta)
            } else if(GameState.playerState == "changing color") {
                
            }
        } else if(GameState.state == "rotating") {
            if(GameState.playerState == "free") {
                checkInputForMovement()
                
                move(delta: delta)
            } else if(GameState.playerState == "rotating") {
                rotate(delta: delta)
            }
        }
        
        //updateSprite()
    }
    
    func checkInputForMovement() {
        movingRight = false
        movingLeft = false
        jumping = false
        
        for t in InputController.currentTouches {
            if(t != nil) {
                //jump if touched top half of the screen
                if(t!.y > 0) {
                    jumping = true
                    
                    //move left if touched bottom left
                } else if(t!.x < 0) {
                    movingLeft = true
                    
                    //move right if touched bottom right
                } else {
                    movingRight = true
                }
            }
        }
    }
    
    override func checkForCollision(with: [Entity]) {
        if(GameState.playerState == "free") {
            canHingeLeft = false
            canHingeRight = false
            
            checkNorthSouthCollision(with: with)
            checkEastWestCollision(with: with)
            
                if(x == Double(Int(x)) && y == Double(Int(y)) && xVel == 0 && yVel == 0) {
                    for t in InputController.currentTouches {
                        if(t != nil) {
                            if(t!.y < 0) {
                                if(t!.x < 0 && canHingeLeft) {
                                    GameState.playerState = "rotating"
                                    GameState.hingeDirection = "left"
                                    rotationVel = 0.1
                                    rotation = 0.0
                                } else if(t!.x >= 0 && canHingeRight) {
                                    GameState.playerState = "rotating"
                                    GameState.hingeDirection = "right"
                                    rotationVel = -0.1
                                    rotation = 0.0
                                }
                            }
                        }
                    }
            }
        }
    }
    
    func checkNorthSouthCollision(with: [Entity]) {
        for entity in with {
            
            //following code cotains collision instruction for blocks and moving blocks only, in the y direction
            if(entity.name == "block" || entity.name == "moving block") {
                
                //make sure the player is able to collide with the current block or moving block by the collision rules defined by entity class
                if(entityCollides(this: self, with: entity)) {
                    
                    let colAcc = 0.001
                    
                    if(yVel > 0) {
                        if(rectContainsPoint(rect: CGRect.init(x: entity.nextX, y: entity.nextY-1, width: 1.0, height: 1.0), point: CGPoint(x: x + colAcc, y: nextY)) || rectContainsPoint(rect: CGRect.init(x: entity.nextX, y: entity.nextY-1, width: 1.0, height: 1.0), point: CGPoint(x: x + 1 - colAcc, y: nextY)) )  {
                            
                            nextY = entity.nextY - 1
                            //print(" \(nextY)")
                            yVel = 0
                            //print(" hit ground, with block at \(Int(entity.x)), \(Int(entity.y))  xmod = \(xMod)")
                        }
                    } else if(yVel < 0) {
                        if(rectContainsPoint(rect: CGRect.init(x: entity.nextX, y: entity.nextY-1, width: 1.0, height: 1.0), point: CGPoint(x: (nextX +         0.5), y: (nextY - (sqrt(3.0) / 2.0)) + colAcc))) {
                            
                            nextY = entity.nextY + (sqrt(3.0) / 2.0) + 2*colAcc
                            yVel = 0
                            //print(" hit ceiling, with block at \(Int(entity.x)), \(Int(entity.y))  xmod = \(xMod)")
                        }
                    }
                    //print("  \(nextX) - \(nextY)")
                }
            }
        }
    }
    
    func checkEastWestCollision(with: [Entity]) {
        for entity in with {
            
            //following code cotains collision instruction for blocks and moving blocks only, in the x direction
            if(entity.name == "block" || entity.name == "moving block") {
                
                //make sure the player is able to collide with the current block or moving block by the collision rules defined by entity class
                if(entityCollides(this: self, with: entity)) {
                    var xMod = 0.0
                    var yMod = 0.0
                    
                    let colAcc = 0.001
                    
                    //check for collision in multiple points throughout the edges of the player
                    let step = 50.0
                    for posInEdge in stride(from: 0.0, through: 1.0, by: (1.0 / step)) {
                        xMod = posInEdge/2
                        yMod = posInEdge * (sqrt(3.0) / -2.0)
                        if(rectContainsPoint(rect: CGRect.init(x: entity.nextX, y: entity.nextY-1, width: 1.0, height: 1.0), point: CGPoint(x: (nextX + xMod), y: (nextY + yMod - colAcc))) && entity.nextX + 0.5 < x) {
                            nextX = entity.nextX + 1 - xMod
                            if(posInEdge <= 2.0 / step) {
                                nextX = entity.nextX + 1
                                if(entity.nextX == Double(Int(entity.nextX)) && entity.nextY == Double(Int(entity.nextY))) {
                                    canHingeLeft = true
                                }
                            }
                            xVel = 0
                            //print(" hit edge, with block at \(Int(entity.nextX)), \(Int(entity.nextY))  xmod = \(xMod)")
                        }
                        if(rectContainsPoint(rect: CGRect.init(x: entity.nextX, y: entity.nextY-1, width: 1.0, height: 1.0), point: CGPoint(x: (nextX + 1 - xMod - colAcc), y: (nextY + yMod - colAcc))) && entity.nextX + 0.5 > x) {
                            nextX = entity.nextX - 1 + xMod
                            if(posInEdge <= 2.0 / step) {
                                nextX = entity.nextX - 1
                                if(entity.nextX == Double(Int(entity.nextX)) && entity.nextY == Double(Int(entity.nextY))) {
                                    canHingeRight = true
                                }
                            }
                            xVel = 0
                            //print(" hit edge, with block at \(Int(entity.nextX)), \(Int(entity.nextY))  xmod = \(xMod)")
                        }
                        //print("  \(nextX) - \(nextY)")
                    }
                } else {
                    if(entity.name == "block" && ((entity as! Block).type == 3 || (entity as! Block).type == 4) && Board.direction == (entity as! Block).direction) {
                        let b = entity as! Block
                        if(nextY == Double(Int(nextY)) && y == entity.y && ((x <= entity.x && nextX >= entity.x) || (x >= entity.x && nextX <= entity.x))) {
                            if(b.type == 3 && b.colorIndex2 != colorIndex) {
                                nextX = entity.nextX
                                xVel = 0
                                
                                newColorIndex = b.colorIndex2
                                newColor = loadColor(colIndex: newColorIndex)
                                loadColorEffect()
                                GameState.beginChangingColor()
                            } else if(b.type == 4) {
                                nextX = entity.nextX
                                xVel = 0
                                
                                newColorIndex = -1
                                newColor = b.color
                                GameState.exitTarget = b.exitTarget!
                                loadColorEffect()
                                GameState.beginChangingColor()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func finishedChangingColor() {
        color = newColor
        colorIndex = newColorIndex
        newColorIndex = -1
        newColor = loadColor(colIndex: newColorIndex)
        sprite[0].fillColor = color
        sprite[0].removeAllChildren()
        
        collidesWithType = [0]
        collidesWithType.append(colorIndex+10)
        
        if(colorIndex == -1) {
            GameState.beginStageTransition()
        }
    }
}
