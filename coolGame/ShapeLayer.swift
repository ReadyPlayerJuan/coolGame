//
//  ShapeLayer.swift
//  Drawing Test
//
//  Created by Erin Seel on 11/25/16.
//  Copyright © 2016 Nick Seel. All rights reserved.
//

import Foundation
import SpriteKit

class RectangleLayer: CAShapeLayer {
    var color: CGColor!
    var rectangle: CGRect!
    
    override init() {
        super.init()
        
        color  = UIColor.red.cgColor
        rectangle = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
        
        path = getRectanglePath().cgPath
    }
    
    init(rect: CGRect, col: CGColor) {
        super.init()
        
        color  = col
        rectangle = rect
        
        path = getRectanglePath().cgPath
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getRectanglePath() -> UIBezierPath {
        fillColor = color
        strokeColor = color
        
        lineWidth = 0.0
        lineCap = kCALineCapRound
        lineJoin = kCALineJoinRound
        
        var rectanglePath = UIBezierPath()
        
        rectanglePath = UIBezierPath(rect: rectangle)
        
        rectanglePath.close()
        return rectanglePath
    }
}

func getTrianglePath(corner: CGPoint, rotation: Double, size: Double) -> CGPath {
    let path = UIBezierPath()
    path.lineWidth = 0.0
    
    let pi = 3.14159
    let trianglePath = UIBezierPath()
    
    trianglePath.move(to: CGPoint(x: corner.x, y: corner.y))
    trianglePath.addLine(to: CGPoint(x: corner.x + CGFloat(size*cos(rotation+(pi/3))),
                                     y: corner.y + CGFloat(size*sin(rotation+(pi/3))) ) )
    trianglePath.addLine(to: CGPoint(x: corner.x + CGFloat(size*cos(rotation)),
                                     y: corner.y + CGFloat(size*sin(rotation)) ) )
    
    trianglePath.close()
    return trianglePath.cgPath
}

class TriangleLayer: CAShapeLayer {
    var color: CGColor!
    var cornerPoint: CGPoint!
    var rotation: Double!
    var size: Double!
    
    override init() {
        super.init()
        
        color  = UIColor.red.cgColor
        cornerPoint = CGPoint(x: 0, y: 0)
        rotation = 0.0
        size = 100.0
        
        path = getTrianglePath().cgPath
    }
    
    init(col: CGColor, corner: CGPoint, rotate: Double, sideLength: Double) {
        super.init()
        
        color = col
        cornerPoint = corner
        rotation = rotate
        size = sideLength
        
        path = getTrianglePath().cgPath
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getTrianglePath() -> UIBezierPath {
        fillColor = color
        strokeColor = color
        
        lineWidth = 0.0
        lineCap = kCALineCapRound
        lineJoin = kCALineJoinRound
        
        let pi = 3.14159
        let trianglePath = UIBezierPath()
        
        trianglePath.move(to: CGPoint(x: cornerPoint.x, y: cornerPoint.y))
        trianglePath.addLine(to: CGPoint(x: cornerPoint.x + CGFloat(size*cos(rotation-(pi/3))),
                                         y: cornerPoint.y + CGFloat(size*sin(rotation-(pi/3))) ) )
        trianglePath.addLine(to: CGPoint(x: cornerPoint.x + CGFloat(size*cos(rotation)),
                                         y: cornerPoint.y + CGFloat(size*sin(rotation)) ) )
        
        trianglePath.close()
        return trianglePath
    }
}
