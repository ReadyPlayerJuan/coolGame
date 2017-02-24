//
//  Stage.swift
//  coolGame
//
//  Created by Nick Seel on 1/9/17.
//  Copyright © 2017 Nick Seel. All rights reserved.
//

import Foundation
import SpriteKit

class Stage {
    public static let defaultStage = "b1.1.1.1.1,1.0.0.0.1,1.0.0.0.1,1.0.0.-11.1,1.1.1.1.1es1.3ex3.3.0emtestName"
    
    var children: [Stage] = []
    var parent: Stage?
    var name: String = "Unnamed"
    
    var blocks: [[Int]]
    var exitTargets: [[Int]]
    var otherEntities: [Entity]! = []
    var spawnPoint: CGPoint!
    
    init(withBlocks: [[Int]], entities: [Entity], spawn: CGPoint, withName: String, exits: [[Int]]) {
        blocks = withBlocks
        name = withName
        spawnPoint = spawn
        otherEntities = entities
        exitTargets = exits
    }
    
    func getEntities() -> [Entity] {
        var temp: [Entity] = []
        
        for e in otherEntities {
            temp.append(e.duplicate())
        }
        
        return temp
    }
    
    func addChild(child: Stage) {
        children.append(child)
        child.parent = self
    }
    
    func numChildren() -> Int {
        return children.count
    }
    
    enum LoadStageError: Error {
        case invalidCode
    }
    
    class func loadStage(code: String) -> Stage {
        var blocks = [[Int]]()
        var entities = [Entity]()
        var spawn = [Int]()
        var exits = [[Int]]()
        var name = ""
        
        var currentAction = ""
        var index = 0
        var entityType = 0
        var parameters = [String]()
        
        var invalid = false
        var completed = false
        while(index < code.length() && !invalid && !completed) {
            if(currentAction == "") {
                currentAction = code.charAt(index)
                index += 1
                
                if(currentAction == "n") {
                    let a = code.charAt(index).toInt()
                    if(a != nil) {
                        entityType = a!
                    } else {
                        invalid = true
                        currentAction = ""
                    }
                    index += 1
                }
            }
            
            if(currentAction == "b") {
                var addParams = false
                
                if(code.charAt(index) == "e") {
                    addParams = true
                    currentAction = ""
                } else if(code.charAt(index) == ",") {
                    addParams = true
                }
                
                if(addParams) {
                    blocks.append([Int]())
                    
                    for s in parameters {
                        let a = s.toInt()
                        if(a != nil) {
                            blocks[blocks.count-1].append(a!)
                        } else {
                            invalid = true
                        }
                    }
                    
                    parameters = [String]()
                    index += 1
                } else {
                    var num = ""
                    
                    while(code.charAt(index) != "." && code.charAt(index) != "," && code.charAt(index) != "e") {
                        num = "\(num)\(code.charAt(index))"
                        index += 1
                    }
                    if(code.charAt(index) == ".") {
                        index += 1
                    }
                    
                    parameters.append(num)
                }
            } else if(currentAction == "n") {
                var num = ""
                
                while(code.charAt(index) != "." && code.charAt(index) != "e") {
                    num = "\(num)\(code.charAt(index))"
                    index += 1
                }
                parameters.append(num)
                
                if(code.charAt(index) == "e") {
                    var e = Entity()
                    
                    switch(entityType) {
                    case 0:
                        let checkParams = [(parameters[0]).toInt(), (parameters[1]).toInt(), (parameters[2]).toInt(), (parameters[3]).toInt()]
                        for p in checkParams {
                            if(p == nil) {
                                invalid = true
                            }
                        }
                        if(!invalid) {
                            e = MovingBlock.init(color: (parameters[0]).toInt()!, dir: (parameters[1]).toInt()!, xPos: (parameters[2]).toDouble()!, yPos: (parameters[3]).toDouble()!)
                        }
                        break
                    default:
                        e = Entity()
                        break
                    }
                    
                    if(!invalid) {
                        entities.append(e)
                    }
                    parameters = [String]()
                    currentAction = ""
                }
                
                index += 1
            } else if(currentAction == "s") {
                for _ in 0...1 {
                    var num = ""
                    
                    while(code.charAt(index) != "." && code.charAt(index) != "e") {
                        num = "\(num)\(code.charAt(index))"
                        index += 1
                    }
                    if(code.charAt(index) == "e") {
                        currentAction = ""
                    }
                    
                    let a = num.toInt()
                    if(a != nil) {
                        spawn.append(a!)
                    } else {
                        invalid = true
                    }
                    index += 1
                }
            } else if(currentAction == "x") {
                var num = ""
                
                while(code.charAt(index) != "." && code.charAt(index) != "," && code.charAt(index) != "e") {
                    num = "\(num)\(code.charAt(index))"
                    index += 1
                }
                parameters.append(num)
                
                if(code.charAt(index) == "e" || code.charAt(index) == ",") {
                    exits.append([Int]())
                    for s in parameters {
                        if(!invalid) {
                            let a = s.toInt()
                            if(a != nil) {
                                exits[exits.count-1].append(a!)
                            } else {
                                invalid = true
                            }
                        }
                    }
                    parameters = [String]()
                    
                    if(code.charAt(index) == "e") {
                        currentAction = ""
                    }
                }
                
                index += 1
            } else if(currentAction == "m") {
                name = ""
                while(index < code.length()) {
                    name = "\(name)\(code.charAt(index))"
                    index += 1
                }
                completed = true
            }
        }
        
        if(invalid) {
            return Stage.loadStage(code: Stage.defaultStage)
        }
        return Stage.init(withBlocks: blocks, entities: entities, spawn: CGPoint(x: spawn[0], y: spawn[1]), withName: name, exits: exits)
    }
}
