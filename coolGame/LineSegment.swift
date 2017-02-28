//
//  LineSegment.swift
//  coolGame
//
//  Created by Nick Seel on 2/12/17.
//  Copyright © 2017 Nick Seel. All rights reserved.
//

import Foundation
import SpriteKit

class LineSegment {
    var points: [CGPoint]
    var vertical = false
    var info: Double
    var distance: CGFloat
    
    init(_ p1: CGPoint, _ p2: CGPoint) {
        points = [p1, p2]
        vertical = (p1.x == p2.x)
        info = 999
        distance = hypot(p1.y-p2.y, p1.x-p2.x)
    }
    
    func equals(_ ls: LineSegment) -> Bool {
        return (ls.points[0].x == points[0].x && ls.points[0].y == points[0].y &&
            ls.points[1].x == points[1].x && ls.points[1].y == points[1].y) ||
            (ls.points[1].x == points[0].x && ls.points[1].y == points[0].y &&
                ls.points[0].x == points[1].x && ls.points[0].y == points[1].y)
    }
    
    func distanceTo(point: CGPoint) -> Double {
        let cenx = (points[0].x+points[1].x)/2.0
        let ceny = (points[0].y+points[1].y)/2.0
        return hypot(Double(cenx)-Double(point.x), Double(ceny)-Double(point.y))
    }
}
