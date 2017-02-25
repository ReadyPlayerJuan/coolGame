//
//  GameScene.swift
//  another test game
//
//  Created by Erin Seel on 12/3/16.
//  Copyright © 2016 Nick Seel. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class MenuScene: SKScene {
    static let screenHeight = UIScreen.main.fixedCoordinateSpace.bounds.width
    static let screenWidth = UIScreen.main.fixedCoordinateSpace.bounds.height
    
    var mainView: SKView!
    var controller: MenuViewController!
    
    var title: MenuButton!
    var startGame: MenuButton!
    var startEditor: MenuButton!
    var startInstructions: MenuButton!
    
    override func didMove(to view: SKView) {
        mainView = view
        backgroundColor = Board.backgroundColor
        
        let width = Int(GameState.screenHeight / 1.8)
        let height = Int(GameState.screenHeight / 5.0)
        let border = Int(GameState.screenHeight / 40.0)
        let numItems = 4
        var currentItemIndex = 0
        
        
        var bgcolor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        var txcolor = UIColor.init(red: 0.9, green: 0.4, blue: 0.9, alpha: 1.0)
        title = MenuButton.init(x: -width/2, y: -height/2 - (currentItemIndex * (height + border)) + Int((Double(numItems-1)/2.0) * Double(height + border)), width: width, height: height, text: "clever witty title", textColor: txcolor, color: bgcolor)
        (title.sprite.children[0] as! SKLabelNode).fontName = "KohinoorBangla-Regular"
        view.scene?.addChild(title.sprite)
        
        currentItemIndex += 1
        bgcolor = UIColor.init(red: 0.7, green: 0.2, blue: 0.2, alpha: 1.0)
        txcolor = UIColor.init(red: 0.9, green: 0.4, blue: 0.4, alpha: 1.0)
        startGame = MenuButton.init(x: -width/2, y: -height/2 - (currentItemIndex * (height + border)) + Int((Double(numItems-1)/2.0) * Double(height + border)), width: width, height: height, text: "game", textColor: txcolor, color: bgcolor)
        view.scene?.addChild(startGame.sprite)
        
        currentItemIndex += 1
        bgcolor = UIColor.init(red: 0.2, green: 0.7, blue: 0.2, alpha: 1.0)
        txcolor = UIColor.init(red: 0.4, green: 0.9, blue: 0.4, alpha: 1.0)
        startEditor = MenuButton.init(x: -width/2, y: -height/2 - (currentItemIndex * (height + border)) + Int((Double(numItems-1)/2.0) * Double(height + border)), width: width, height: height, text: "editor", textColor: txcolor, color: bgcolor)
        view.scene?.addChild(startEditor.sprite)
        
        currentItemIndex += 1
        bgcolor = UIColor.init(red: 0.2, green: 0.2, blue: 0.7, alpha: 1.0)
        txcolor = UIColor.init(red: 0.4, green: 0.4, blue: 0.9, alpha: 1.0)
        startInstructions = MenuButton.init(x: -width/2, y: -height/2 - (currentItemIndex * (height + border)) + Int((Double(numItems-1)/2.0) * Double(height + border)), width: width, height: height, text: "info", textColor: txcolor, color: bgcolor)
        view.scene?.addChild(startInstructions.sprite)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        InputController.touchesBegan(touches, node: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        InputController.touchesMoved(touches, node: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        InputController.touchesEnded(touches, node: self)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        InputController.touchesCancelled(touches, node: self)
    }
    
    override func update(_ currentTime: TimeInterval) {
        startGame.update()
        startEditor.update()
        startInstructions.update()
        
        if(startGame.isPressed) {
            controller.goToScene("game")
        }
        if(startEditor.isPressed) {
            controller.goToScene("editor")
        }
        if(startInstructions.isPressed) {
            controller.goToScene("instructions")
        }
    }
}
