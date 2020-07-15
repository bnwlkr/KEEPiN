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
    func requestUsername(leaderboardManager: LeaderboardManager)
}

class GameViewController: UIViewController, ViewControllerDelegate  {

	var leaderboardHostingVC: UIHostingController<LeaderboardView>?
	var alertController: UIAlertController!
	let msg1 = "Create a username if you'd like to participate in the KEEPiN leaderboard\n\n4 - 16 characters  "
	let msg2 = "\nDoes not exist       "
	var isUsernameCorrectLength: Bool {
		get {
			return _isUsernameCorrectLength
		} set {
			_isUsernameCorrectLength = newValue
			alertController.message = msg1 + (newValue ? "✅" : "⛔️") + msg2 + (doesUsernameExist ? "⛔️" : "✅")
		}
	}
	var doesUsernameExist: Bool {
		get {
			return _doesUsernameExist
		} set {
			_doesUsernameExist = newValue
			alertController.message = msg1 + (isUsernameCorrectLength ? "✅" : "⛔️") + msg2 + (newValue ? "⛔️" : "✅")
		}
	}
	var _isUsernameCorrectLength = false
	var _doesUsernameExist = false
	
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

	@objc func textChanged(sender: UITextField) {
		self.alertController.actions[1].isEnabled = false
		if let currentInput = sender.text {
			if currentInput.count >= 4 && currentInput.count <= 16 {
				self.isUsernameCorrectLength = true
				LeaderboardManager.existsUser(username: currentInput, completion: {	exists in
					self.doesUsernameExist = exists
					if !exists {
						self.alertController.actions[1].isEnabled = true
					} else {
						self.alertController.actions[1].isEnabled = false
					}
				})
			} else {
				self.isUsernameCorrectLength = false
				self.alertController.actions[1].isEnabled = false
			}
		}
	}

	func requestUsername(leaderboardManager: LeaderboardManager) {
		self.alertController = UIAlertController(title: "Create Username", message: "", preferredStyle: .alert)
		isUsernameCorrectLength = false
		doesUsernameExist = false
		
		let submitAction = UIAlertAction(title: "Submit", style: UIAlertAction.Style.default) {
			  UIAlertAction in
			let username = self.alertController.textFields![0].text!
			LeaderboardManager.newHighscore(username: username, highscore: KeyChain.highscore, success: {
				KeyChain.username = username
				leaderboardManager.getLeaderboard()
			})
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
			UIAlertAction in
			NSLog("Cancel Pressed")
		}
		
		alertController.addAction(cancelAction)
		alertController.addAction(submitAction)
		alertController.addTextField { (textField) in
		   textField.placeholder = "Username"
		   textField.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
		}
		
		alertController.actions[1].isEnabled = false

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

