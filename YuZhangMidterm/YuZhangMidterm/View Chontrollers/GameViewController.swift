//
//  GameViewController.swift
//  YuZhangMidterm
//
//  Created by Xcode User on 2020-10-24.
//  Copyright © 2020 Xcode User. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
//    var timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            // step 2 of segue from gameScene to viewController
            // change SKScene to GameScene
            if let scene = GameScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // step 3 add this two line
                scene.viewController = self
                self.dismiss(animated: true, completion: nil)
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
//        scheduledTimerWithTimeInterval()
    }
    
//    func scheduledTimerWithTimeInterval(){
//        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
//    }
//
//    @objc func updateCounting(){
//        NSLog("counting..")
//    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
