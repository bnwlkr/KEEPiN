//
//  GameViewController.swift
//  keepin
//
//  Created by Ben Walker on 2017-06-21.
//  Copyright © 2017 Ben Walker. All rights reserved.
//

import UIKit
import SwiftUI
import SpriteKit
import GameplayKit

protocol ViewControllerDelegate {
    func presentLeaderboard()
}

class GameViewController: UIViewController, ViewControllerDelegate  {

	
	override func viewDidLoad() {
        super.viewDidLoad()
    
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                scene.viewControllerDelegate = self
                
                // Present the scene
                view.presentScene(scene)
            }
            view.ignoresSiblingOrder = true
        }
        
	}


	func presentLeaderboard() {
		let vc = UIHostingController(rootView: LeaderboardView())
		self.present(vc, animated: true, completion: nil)
	}
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override var shouldAutorotate: Bool {
        return false
        
    }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

}

