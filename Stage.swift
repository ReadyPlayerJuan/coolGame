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
    var playerAbilities = Player.maxAbilities
    var colorTheme = 0
    
    var infoScreens = [Int]()
    
    var ID: Int
    
    init(withBlocks: [[Int]], entities: [Entity], spawn: CGPoint, withName: String, exits: [[Int]], colorTheme: Int) {
        ID = Stage.getID()
        
        blocks = withBlocks
        name = withName
        spawnPoint = spawn
        otherEntities = entities
        exitTargets = exits
        self.colorTheme = colorTheme
    }
    
    static var nextID = 0
    class func getID() -> Int {
        nextID += 1
        return nextID-1
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
    
    func findStageWithID(_ targetID: Int, baseID: Int) -> Stage? {
        if(ID == targetID) {
            return self
        } else {
            for c in children {
                if(c.ID != baseID) {
                    if(c.findStageWithID(targetID, baseID: baseID) != nil) {
                        return c.findStageWithID(targetID, baseID: baseID)
                    }
                }
            }
        }
        return nil
    }
    
    /*
     stage writing guide:
     - stage arrays must be rectangular
     - spawnpoint and overlayed entities must be defined after instantiating stage array
     
     - code for block types:
     - 0 is black passable block
     - 1 is white impassable block
     - 2-8 are colored blocks, color is in ColorTheme with index n-2
     - -9 is invisible impassable block, to create illusion of no blocks
     - -AB is end gate, where A-1 is direction and B-2 is colorIndex of surrounding block
     - ABC is color change, where A is direction, B-2 is colorIndex of surrounding block, and c-2 is colorIndex of color change triangle
     - 99 is a hazard block
     */
    
    class func loadTestingArea() -> Stage {
        let stage =   [ [1, 1, 1, 1, 1, 1, 1, 1, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 0, 0, 0, 0, 2, 0, 0, 1],
                        [1, 0, 2, 0, 0, 0, 0, 0, 1],
                        [1, 0, 2, 0, 0, 0, 0, 0, 1],
                        [1, 0, 0, 0, 2, 0, 0, 0, 1],
                        [1, 0, 0, 2, 0, 0, 2,-11,1],
                        [1, 1, 1, 1, 1, 1, 1, 1, 1] ]
        let spawnPoint = CGPoint(x: 1, y: 6)
        let exitTargets = [[7, 6, 0]]
        let otherEntities: [Entity] = [LightSource.init(type: 0, xPos: 4.0, yPos: 3), MovingBlock.init(color: 2, dir: 1, xPos: 3, yPos: 1)]
        
        let s = Stage.init(withBlocks: stage, entities: otherEntities, spawn: spawnPoint, withName: "", exits: exitTargets, colorTheme: 1)
        StageSet2.loadStages(base: s)
        return s
    }
    
    class func loadStage(code: String) -> Stage {
        var blocks = [[Int]]()
        var entities = [Entity]()
        var spawn = [Int]()
        var exits = [[Int]]()
        var name = ""
        var colorTheme = 0
        
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
            } else if(currentAction == "c") {
                colorTheme = code.charAt(index).toInt()!
                index += 1
                currentAction = ""
            }
        }
        
        if(invalid) {
            return Stage.loadStage(code: Stage.defaultStage)
        }
        return Stage.init(withBlocks: blocks, entities: entities, spawn: CGPoint(x: spawn[0], y: spawn[1]), withName: name, exits: exits, colorTheme: colorTheme)
    }
}
