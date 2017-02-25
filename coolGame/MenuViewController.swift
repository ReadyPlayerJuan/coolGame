//
//  GameViewController.swift
//  another test game
//
//  Created by Erin Seel on 12/3/16.
//  Copyright © 2016 Nick Seel. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class MenuViewController: UIViewController {
    static var mainView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            MenuViewController.mainView = view
            
            if let scene = SKScene(fileNamed: "MenuScene") {
                (scene as! MenuScene).controller = self
                scene.scaleMode = .resizeFill
                
                view.presentScene(scene)
            }
            
            view.isMultipleTouchEnabled = true
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
            view.shouldCullNonVisibleNodes = true
        }
    }
    
    func goToScene(_ name: String) {
        InputController.resetTouches()
        
        if let view = self.view as! SKView? {
            
            if(name == "menu") {
                if let scene = SKScene(fileNamed: "MenuScene") {
                    (scene as! MenuScene).controller = self
                    scene.scaleMode = .resizeFill
                    
                    view.presentScene(scene)
                }
            } else if(name == "game") {
                if let scene = SKScene(fileNamed: "GameScene") {
                    (scene as! GameScene).controller = self
                    scene.scaleMode = .resizeFill
                    
                    view.presentScene(scene)
                }
            } else if(name == "editor") {
                if let scene = SKScene(fileNamed: "EditorScene") {
                    (scene as! EditorScene).controller = self
                    scene.scaleMode = .resizeFill
                    
                    view.presentScene(scene)
                }
            } else if(name == "instructions") {
                if let scene = SKScene(fileNamed: "InfoScene") {
                    (scene as! InfoScene).controller = self
                    scene.scaleMode = .resizeFill
                    
                    view.presentScene(scene)
                }
            }
            
            view.isMultipleTouchEnabled = true
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
            view.shouldCullNonVisibleNodes = true
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .landscape
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
