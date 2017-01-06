//
//  InputController.swift
//  Drawing Test
//
//  Created by Erin Seel on 11/26/16.
//  Copyright © 2016 Nick Seel. All rights reserved.
//

import Foundation
import GameplayKit

class InputController {
    
    static var currentTouches: [CGPoint?] = [nil, nil, nil]
    static var numCurrentTouches = 0
    static let maxTouchLeniency = CGFloat(100.0)
    
    static func resetTouches() {
        currentTouches = [nil, nil, nil]
        numCurrentTouches = 0
    }
    
    static func touchesBegan(_ touches: Set<UITouch>, node: SKNode) {
        for t in touches {
            if(numCurrentTouches < 3) {
                currentTouches[numCurrentTouches] = t.location(in: node)
                numCurrentTouches += 1
            }
        }
    }
    
    static func touchesMoved(_ touches: Set<UITouch>, node: SKNode) {
        for t in touches {
            for index in 0...2 {
                let pt = currentTouches[index]
                if(pt != nil) {
                    if(hypot(t.previousLocation(in: node).x-(pt?.x)!, t.previousLocation(in: node).y-(pt?.y)!) < maxTouchLeniency) {
                        currentTouches[index] = t.location(in: node)
                    }
                }
            }
        }
    }
    
    static func touchesEnded(_ touches: Set<UITouch>, node: SKNode) {
        for t in touches {
            for index in 0...2 {
                let pt = currentTouches[index]
                if(pt != nil) {
                    if(hypot(t.location(in: node).x-(pt?.x)!, t.location(in: node).y-(pt?.y)!) < maxTouchLeniency) {
                        currentTouches[index] = nil
                        numCurrentTouches -= 1
                        
                        var temp: [CGPoint?] = [nil, nil, nil]
                        var count = 0
                        for index in 0...2 {
                            if(currentTouches[index] != nil) {
                                temp[count] = currentTouches[index]
                                count += 1
                            }
                        }
                        currentTouches = temp
                    }
                }
            }
        }
    }
    
    static func touchesCancelled(_ touches: Set<UITouch>, node: SKNode) {
        for t in touches {
            for index in 0...2 {
                let pt = currentTouches[index]
                if(pt != nil) {
                    if(hypot(t.location(in: node).x-(pt?.x)!, t.location(in: node).y-(pt?.y)!) < maxTouchLeniency) {
                        currentTouches[index] = nil
                        numCurrentTouches -= 1
                        
                        var temp: [CGPoint?] = [nil, nil, nil]
                        var count = 0
                        for index in 0...2 {
                            if(currentTouches[index] != nil) {
                                temp[count] = currentTouches[index]
                                count += 1
                            }
                        }
                        currentTouches = temp
                    }
                }
            }
        }
    }
}
