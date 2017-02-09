//
//  StageSet1.swift
//  coolGame
//
//  Created by Nick Seel on 1/9/17.
//  Copyright © 2017 Nick Seel. All rights reserved.
//

import Foundation
import SpriteKit

class StageSet1 {
    class func loadStages(base: Stage) {
        let s0 = getStage(index: 0)
        let s1 = getStage(index: 1)
        let s2 = getStage(index: 2)
        let s3 = getStage(index: 3)
        let s4 = getStage(index: 4)
        
        base.addChild(child: s0)
        s0.addChild(child: s1)
        s1.addChild(child: s2)
        s2.addChild(child: s3)
        s3.addChild(child: s4)
    }
    
    class func getStage(index: Int) -> Stage {
        var stage: [[Int]]? = nil
        var spawnPoint = CGPoint(x: -1, y: -1)
        var otherEntities: [Entity] = []
        var exitTargets: [[Int]]!
        var name = "nope, no name today"
        
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
        */
        
        switch(index) {
        case 0:
            stage =   [ [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1],
                        [1, 0, 0, 0, 0, 0, 0,-11,0, 0, 0, 0, 0, 1],
                        [1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1] ]
            spawnPoint = CGPoint(x: 3, y: 4)
            exitTargets = [[7, 3, 0]]
            name = "platform parkour"; break
        case 1:
            stage =   [ [-9,-9,-9,-9,-9,-9,-9,1, 1, 1, 1, 1, 1],
                        [-9,-9,-9,-9,-9,-9,-9,1, 0, 0,-31,0, 1],
                        [-9,-9,-9,-9,1, 1, 1, 1, 0, 0, 0, 0, 1],
                        [-9,-9,-9,-9,1, 0, 0, 0, 0, 0, 0, 0, 1],
                        [-9,-9,-9,-9,1, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 1,-9,-9,-9,-9],
                        [1, 0, 0, 0, 0, 0, 0, 0, 1,-9,-9,-9,-9],
                        [1, 0, 0, 0, 0, 1, 1, 1, 1,-9,-9,-9,-9],
                        [1, 0, 0, 0, 0, 1,-9,-9,-9,-9,-9,-9,-9],
                        [1, 1, 1, 1, 1, 1,-9,-9,-9,-9,-9,-9,-9] ]
            spawnPoint = CGPoint(x: 2, y: 9);
            exitTargets = [[10, 1, 0]]
            name = "rotating rectangles"; break
        case 2:
            stage =   [ [1, 1, 1, 1, 1, 1, 1, 1, 1,-9,-9, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                        [1, 0, 0, 0, 0, 0,212,0, 1,-9,-9, 1, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 4, 4, 0, 0, 0, 1],
                        [1, 0, 3, 0, 0, 0, 0, 0, 3, 2, 2, 3, 0, 0, 0, 0, 0, 4, 0, 1],
                        [1, 0, 0, 0, 1,314,0, 0, 3, 2, 2, 3, 0, 4, 0, 0,-21,4, 0, 1],
                        [1, 0, 2, 0, 0, 0, 0, 0, 3, 2, 2, 3, 0, 4, 0, 0, 0, 0, 0, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 4, 4, 0, 0, 1],
                        [1, 0, 0, 0, 0, 0,013,0, 1,-9,-9, 1, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 1, 1, 1, 1, 1, 1, 1, 1,-9,-9, 1, 1, 1, 1, 1, 1, 1, 1, 1] ]
            //otherEntities.append(MovingBlock.init(color: 0, dir: 0, xPos: 2, yPos: 1))
            spawnPoint = CGPoint(x: 4, y: 6);
            exitTargets = [[16, 4, 0]]
            name = "colorful creations"; break
        case 3:
            stage =   [ [1, 1, 1, 1, 1, 1, 1, 1, 1,-9,-9, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 1,-9,-9, 1, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 0, 3, 0, 0, 0, 3, 0, 1, 1, 1, 1, 0, 4, 0, 0, 0, 4, 0, 1],
                        [1, 0, 0, 0, 3, 0, 0, 0, 5, 4, 2, 5, 0, 0, 0,017,0, 0, 0, 1],
                        [1, 0, 3, 0,214,0, 3, 0, 5, 4, 2, 5, 0, 0,117,4,317,0, 0, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 5, 4, 2, 5, 0, 0, 0,217,0, 0, 0, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 4, 0, 0, 0, 4, 0, 1],
                        [1, 0, 0, 0, 0, 0,012,0, 1,-9,-9, 1, 0, 0, 0,014,0, 0, 0, 1],
                        [1, 1, 1, 4, 4, 4, 1, 1, 1,-9,-9, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                        [-9,-9,1, 6, 6, 6, 1,-9,-9,-9,-9,-9,-9,-9,-9,-9,-9,-9,-9,-9],
                        [-9,-9,1, 6, 6, 6, 1,-9,-9,-9,-9,-9,-9,-9,-9,-9,-9,-9,-9,-9],
                        [1, 1, 1, 4, 4, 4, 1, 1, 1,-9,-9, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                        [1, 2, 0, 0, 0, 0, 0, 5, 1,-9,-9, 1, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 0, 2, 2, 5, 5, 5, 0, 1, 1, 1, 1, 0, 6, 7, 2, 3, 4, 0, 1],
                        [1, 0, 2, 0, 0, 0, 5, 0, 3, 2, 2, 3, 0, 2, 3, 4, 5, 6, 0, 1],
                        [1, 0, 2,115,2,313,2, 0, 3, 2, 2, 3, 0, 4, 5,-26,7, 2, 0, 1],
                        [1, 0, 5, 0, 0, 0, 2, 0, 3, 2, 2, 3, 0, 6, 7, 2, 3, 4, 0, 1],
                        [1, 0, 5, 5, 5, 2, 2, 0, 1, 1, 1, 1, 0, 2, 3, 4, 5, 6, 0, 1],
                        [1, 5, 0, 0, 0, 0, 0, 2, 1,-9,-9, 1, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 1, 1, 1, 1, 1, 1, 1, 1,-9,-9, 1, 1, 1, 1, 1, 1, 1, 1, 1] ]
            spawnPoint = CGPoint(x: 2, y: 6);
            exitTargets = [[15, 15, 0]]
            name = "room-filled riddle"; break
        case 4:
            stage =   [ [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 0, 0, 0, 0, 0, 0, 4, 3, 4, 4, 4, 0, 0, 0, 5, 0, 0, 1],
                        [1, 0, 6, 0, 2, 0, 0, 3, 2, 4, 0, 4, 5, 5, 0, 0, 0, 0, 1],
                        [1, 0, 0, 2, 0, 4, 0, 2,263,0, 5, 3, 0, 4, 3, 3, 0, 0, 1],
                        [1, 0, 0, 6, 0, 4, 0, 5, 0, 0, 0, 5, 6, 4, 3, 0, 0, 0, 1],
                        [1, 0, 0, 0, 0, 6, 5,376,0, 0, 3, 0, 0, 0, 0, 4, 0, 0, 1],
                        [1, 0, 0, 4, 0, 0, 6,164,3, 5, 2, 0, 3, 0, 6, 4, 0, 0, 1],
                        [1, 0, 0, 4, 0, 0, 2, 4, 3, 3, 2, 2, 0, 4, 6, 0, 0, 0, 1],
                        [1, 0, 0, 0, 0, 2, 0, 4, 0, 0, 0, 0,-27,265,0,0, 0, 0, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 0, 0, 1, 1, 0, 0,012,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1] ]
            spawnPoint = CGPoint(x: 2, y: 10);
            exitTargets = [[12, 9, 0]]
            name = "definitely difficult"; break
        default:
            stage =       [ [1, 1, 1, 1, 1],
                            [1, 0, 0, 0, 1],
                            [1, 0, 0, 0, 1],
                            [1, 0, 0,-11,1],
                            [1, 1, 1, 1, 1] ]
            spawnPoint = CGPoint(x: 1, y: 3);
            exitTargets = [[3, 3, 0]]
            name = "default"; break
        }
        
        return Stage.init(withBlocks: stage!, entities: otherEntities, spawn: spawnPoint, withName: name, exits: exitTargets)
    }
}
