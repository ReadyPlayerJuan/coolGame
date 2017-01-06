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

class EditorViewController: UIViewController {
    var editorscene: EditorScene!
    
    @IBOutlet weak var color0: UIButton!
    @IBOutlet weak var color1: UIButton!
    @IBOutlet weak var color2: UIButton!
    @IBOutlet weak var color3: UIButton!
    @IBOutlet weak var color4: UIButton!
    @IBOutlet weak var color5: UIButton!
    @IBOutlet weak var color6: UIButton!
    @IBOutlet weak var color7: UIButton!
    @IBOutlet weak var color8: UIButton!
    
    @IBAction func pressedColor0(_ sender: Any) {
        editorscene.colorIndex = 99
    }
    @IBAction func pressedColor1(_ sender: Any) {
        editorscene.colorIndex = -2
    }
    @IBAction func pressedColor2(_ sender: Any) {
        editorscene.colorIndex = -1
    }
    @IBAction func pressedColor3(_ sender: Any) {
        editorscene.colorIndex = 0
    }
    @IBAction func pressedColor4(_ sender: Any) {
        editorscene.colorIndex = 1
    }
    @IBAction func pressedColor5(_ sender: Any) {
        editorscene.colorIndex = 2
    }
    @IBAction func pressedColor6(_ sender: Any) {
        editorscene.colorIndex = 3
    }
    @IBAction func pressedColor7(_ sender: Any) {
        editorscene.colorIndex = 4
    }
    @IBAction func pressedColor8(_ sender: Any) {
        editorscene.colorIndex = 5
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "EditorScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                editorscene = scene as! EditorScene
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
        }
        color3.backgroundColor = createColor(rgb: ColorTheme.colors[Board.colorTheme][0])
        color4.backgroundColor = createColor(rgb: ColorTheme.colors[Board.colorTheme][1])
        color5.backgroundColor = createColor(rgb: ColorTheme.colors[Board.colorTheme][2])
        color6.backgroundColor = createColor(rgb: ColorTheme.colors[Board.colorTheme][3])
        color7.backgroundColor = createColor(rgb: ColorTheme.colors[Board.colorTheme][4])
        color8.backgroundColor = createColor(rgb: ColorTheme.colors[Board.colorTheme][5])
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
    
    func createColor(rgb: [Int]) -> UIColor {
        let color = UIColor(red: CGFloat(rgb[0])/256.0, green: CGFloat(rgb[1])/256.0, blue: CGFloat(rgb[2])/256.0, alpha: 1.0)
        return color
    }
}
