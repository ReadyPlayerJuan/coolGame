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
    
    static var prevTouches = [CGPoint]()
    static var currentTouches = [CGPoint]()
    
    static let maxTouchLeniency = CGFloat(100.0)
    
    static func resetTouches() {
        currentTouches = [CGPoint]()
        prevTouches = [CGPoint]()
    }
    
    static func touchesBegan(_ touches: Set<UITouch>, node: SKNode) {
        for t in touches {
            currentTouches.append(t.location(in: node))
        }
    }
    
    static func touchesMoved(_ touches: Set<UITouch>, node: SKNode) {
        for t in touches {
            for i in 0...currentTouches.count-1 {
                let ct = currentTouches[i]
                if(hypot(t.previousLocation(in: node).x-(ct.x), t.previousLocation(in: node).y-(ct.y)) < maxTouchLeniency) {
                    currentTouches[i] = t.location(in: node)
                }
            }
        }
    }
    
    static func touchesEnded(_ touches: Set<UITouch>, node: SKNode) {
        for t in touches {
            var remove = [Int]()
            for i in 0...currentTouches.count-1 {
                let ct = currentTouches[i]
                if(hypot(t.location(in: node).x-(ct.x), t.location(in: node).y-(ct.y)) < maxTouchLeniency) {
                    remove.insert(i, at: 0)
                }
            }
            for i in remove {
                if(i < currentTouches.count) {
                    currentTouches.remove(at: i)
                }
            }
        }
    }
    
    static func touchesCancelled(_ touches: Set<UITouch>, node: SKNode) {
        for t in touches {
            var remove = [Int]()
            for i in 0...currentTouches.count-1 {
                let ct = currentTouches[i]
                if(hypot(t.location(in: node).x-(ct.x), t.location(in: node).y-(ct.y)) < maxTouchLeniency) {
                    remove.insert(i, at: 0)
                }
            }
            for i in remove {
                if(i < currentTouches.count) {
                    currentTouches.remove(at: i)
                }
            }
        }
    }
}
