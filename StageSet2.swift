//
//  StageSet1.swift
//  coolGame
//
//  Created by Nick Seel on 1/9/17.
//  Copyright © 2017 Nick Seel. All rights reserved.
//

import Foundation
import SpriteKit

class StageSet2 {
    class func loadStages(base: Stage) {
        let s0 = getStage(index: 0)
        let s1 = getStage(index: 1)
        let s2 = getStage(index: 2)
        
        base.addChild(child: s0)
        s0.addChild(child: s1)
        s0.addChild(child: s2)
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
            stage =   [ [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 0, 0, 2, 0, 0, 0, 0, 0, 0, 1],
                        [1, 0, 2, 2, 0, 0, 0, 0, 0, 0, 1],
                        [1, 0, 0, 2, 0, 0, 0, 0, 0, 0, 1],
                        [1, 0, 0, 2,-41,0, 0, 0, 0, 0, 1],
                        [1, 0, 2, 2, 2, 0, 0, 0, 0, 0, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 0,-11,1],
                        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1] ]
            spawnPoint = CGPoint(x: 1, y: 6)
            exitTargets = [[9, 7, 0], [4, 5, 1]]; break
        case 1:
            stage =   [ [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 0, 0, 2, 0, 0, 0, 3, 0, 0, 1],
                        [1, 0, 2, 2, 0, 0, 3, 0, 3, 0, 1],
                        [1, 0, 0, 2, 0, 0, 3, 0, 3, 0, 1],
                        [1, 0, 0, 2, 0, 0, 3, 3, 3, 0, 1],
                        [1, 0, 2, 2, 2, 0, 3, 0, 3, 0, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 0,-11,1],
                        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1] ]
            spawnPoint = CGPoint(x: 1, y: 6)
            exitTargets = [[9, 7, 0]]; break
        case 2:
            stage =   [ [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
                        [1, 0, 0, 2, 0, 0, 4, 4, 0, 0, 1],
                        [1, 0, 2, 2, 0, 0, 4, 0, 4, 0, 1],
                        [1, 0, 0, 2, 0, 0, 4, 4, 0, 0, 1],
                        [1, 0, 0, 2, 0, 0, 4, 0, 4, 0, 1],
                        [1, 0, 2, 2, 2, 0, 4, 4, 0, 0, 1],
                        [1, 0, 0, 0, 0, 0, 0, 0, 0,-11,1],
                        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1] ]
            spawnPoint = CGPoint(x: 1, y: 6)
            exitTargets = [[9, 7, 0]]; break
        default:
            stage =       [ [1, 1, 1, 1, 1],
                            [1, 0, 0, 0, 1],
                            [1, 0, 0, 0, 1],
                            [1, 0, 0,-11,1],
                            [1, 1, 1, 1, 1] ]
            spawnPoint = CGPoint(x: 1, y: 3);
            exitTargets = [[3, 3, 0]]; break
        }
        
        return Stage.init(withBlocks: stage!, entities: otherEntities, spawn: spawnPoint, withName: name, exits: exitTargets)
    }
}
