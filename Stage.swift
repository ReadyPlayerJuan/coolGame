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
    
    func addChild(child: Stage) {
        children.append(child)
        child.parent = self
    }
    
    func numChildren() -> Int {
        return children.count
    }
}
