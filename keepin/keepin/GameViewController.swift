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
    func requestUsername()
}

class GameViewController: UIViewController, ViewControllerDelegate  {

	var leaderboardHostingVC: UIHostingController<LeaderboardView>?
	
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

	func requestUsername() {
		let alertController = UIAlertController(title: "Create Username", message: "Create a username if you'd like to participate in the KEEPiN leaderboard", preferredStyle: .alert)
		let okAction = UIAlertAction(title: "Submit", style: UIAlertAction.Style.default) {
			  UIAlertAction in
			  NSLog("Submit Pressed")
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
			UIAlertAction in
			NSLog("Cancel Pressed")
		}
	   alertController.addAction(okAction)
	   alertController.addAction(cancelAction)
	   alertController.addTextField { (textField) in
		   textField.placeholder = "Username"
	   }

		self.leaderboardHostingVC?.present(alertController, animated: true, completion: nil)
	}

	func presentLeaderboard() {
		let vc = UIHostingController(rootView: LeaderboardView(gameVC: self, dismiss: {self.dismiss(animated: true, completion: nil)}))
		vc.overrideUserInterfaceStyle = .dark
		vc.view.alpha = 0.9
		self.leaderboardHostingVC = vc
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

