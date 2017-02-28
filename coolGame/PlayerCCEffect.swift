//
//  PlayerColorChangeEffect.swift
//  coolGame
//
//  Created by Nick Seel on 1/12/17.
//  Copyright © 2017 Nick Seel. All rights reserved.
//

import Foundation
import SpriteKit

extension Player {
    func loadColorChangeEffect() {
        horizontalMovementTimer = 0
        verticalMovementTimer = 0
        sprite[0].removeAllChildren()
        
        let pattern = loadColorChangeEffectPattern()
        let numTriangles = (pattern.count+1)/2
        
        let size = (Double(Board.blockSize) / Double(numTriangles)) + 0.0
        
        let diff = 0.1
        let s = SKShapeNode.init(path: getTrianglePath(corner: CGPoint(x: -diff, y: -0.0), rotation: 0.0, size: size + 2*diff))
        s.strokeColor = UIColor.clear
        s.fillColor = newColor!
        s.zPosition = 1
        
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
    
    func loadColorChangeEffectPattern() -> [[String]] {
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
            code = //"iakkkyyyyyypqyppqyogqxoghrxnahrxnfbirwmecisawmdjsakwlkjskkkvlktkkyyvuutyyyyyvutyyy"
            "dabccddcecbdbacca"
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
                for _ in 0...current.toInt()!-1 {
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
    
    func updateColorChangeEffect() {
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
    
    func finishedChangingColor() {
        color = newColor
        colorIndex = newColorIndex
        newColorIndex = -1
        newColor = loadColor(colIndex: newColorIndex)
        sprite[0].fillColor = color
        sprite[0].removeAllChildren()
        
        collidesWithType = [0]
        if(Board.blocks[Int(y+0.5)][Int(x+0.5)]?.inverted)! {
            collidesWithType.append(colorIndex+20)
        } else {
            collidesWithType.append(colorIndex+10)
        }
        
        if(colorIndex == -1) {
            GameState.beginStageTransition()
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
}
