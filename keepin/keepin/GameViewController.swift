//
//  GameViewController.swift
//  keepin
//
//  Created by Ben Walker on 2017-06-21.
//  Copyright © 2017 Ben Walker. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds



class GameViewController: UIViewController, GADBannerViewDelegate, GADInterstitialDelegate {
    
    var bannerReady = false
    var bannerView = GADBannerView(adSize: kGADAdSizeBanner)
    var interstitial = GADInterstitial(adUnitID: "")
    var onGameScene = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                
                
                // Present the scene
                view.presentScene(scene)
                
                
                    interstitial = createAndLoadInterstitial()
                    interstitial.delegate = self
                    
                    
                    bannerView.rootViewController = self
                    
                    bannerView.adUnitID = ""
                    bannerView.delegate = self
                    //let requestBanner = GADRequest()
                    
                    //bannerView.load(requestBanner)
                    
                    var bannerFrame = bannerView.frame
                    bannerFrame.origin.x = self.view.center.x - bannerFrame.width / 2
                    bannerFrame.origin.y = self.view.frame.height - bannerFrame.size.height
                    bannerView.frame = bannerFrame
                    
                    
                    NotificationCenter.default.addObserver(self, selector: #selector(displayInterstitial), name: Notification.Name("playsReached"), object: nil)
                    NotificationCenter.default.addObserver(self, selector: #selector(showBanner), name: Notification.Name("showBanner"), object: nil)
                    NotificationCenter.default.addObserver(self, selector: #selector(hideBanner), name: Notification.Name("hideBanner"), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(gameSceneTrue), name: Notification.Name("gameSceneTrue"), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(gameSceneFalse), name: Notification.Name("gameSceneFalse"), object: nil)
                
                
            }
            
            view.ignoresSiblingOrder = true

            
        }
        
        
    }
    


    func showBanner () {
        
        if (UserDefaults.standard.integer(forKey: "openCount") > 1) && onGameScene {
            
        bannerView.isHidden = false
        if bannerReady {
            
            self.view.addSubview(bannerView)
            bannerView.alpha = 0
            UIView.animate(withDuration: 1, animations: {
                self.bannerView.alpha = 1
            })
        }
        }
    }
    
    func hideBanner () {
        bannerView.isHidden = true
    }
    
    
    func gameSceneTrue () {
        onGameScene = true
    }
    
    func gameSceneFalse () {
        onGameScene = false
    }
    
    
    func displayInterstitial () {
        
        if (UserDefaults.standard.integer(forKey: "openCount") > 1) {

        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
        print("interstitialDidReceiveAd")
        }
        
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "")
        interstitial.delegate = self
        //interstitial.load(GADRequest())
        return interstitial
    }
    
    
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
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
    
    
    
    
    
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerReady = true
        
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
    
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("ADRECEIVED")
    }
    
    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }
    
    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
    }
    
    
    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
    
}
