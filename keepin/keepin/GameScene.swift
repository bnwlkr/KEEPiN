//
//  GameScene.swift
//  keepin
//
//  Created by Ben Walker on 2017-06-21.
//  Copyright © 2017 Ben Walker. All rights reserved.
//


import SpriteKit
import GameplayKit
import AVFoundation
import Social
import StoreKit
import UIKit
import SwiftUI


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
	let GOLDEN_ASPECT: CGFloat = 0.5625
	let STANDARD_BOUNDARY_WIDTH: CGFloat = 675.0
	let currentAspect = UIScreen.main.bounds.width / UIScreen.main.bounds.height
    
    let GOLDEN_BALL_SHAPE_RATIO: CGFloat = 0.0266
    let GOLDEN_BALL_PHYSICS_BODY_RATIO: CGFloat = 0.0222
    
    var viewControllerDelegate: ViewControllerDelegate?
    
    
    let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 0.4)
    let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.4)
    var sequenceX = SKAction()
    var expandingCircleAction: SKAction!
    
    var firstPlay = true
    
    var xInset: CGFloat = 0.0
    
    
    //sounds
    var audioCongrats: SKAction?
    var audioContact: SKAction?
    var audioClick: SKAction?
    var audioDeath: SKAction?
    var audioTouch: SKAction?
    var audioUrAwesome: SKAction?

    
    // game control
    var transitionColor = UIColor.white
    var canTouch = true
    var alreadyContact = false

    // gameState
    static var gameState: GameState? = nil
    
    // colors
    var myColors = [UIColor.blue, UIColor.cyan, UIColor.green, UIColor.yellow, UIColor.red, UIColor.magenta]
    var colorIndex = Int(arc4random_uniform(6))
    
    static var plays = 0
    
    // sound
    var isMuted = false
    
    // buttons
    var menuButton = SKSpriteNode()
    var leaderboardButton = SKSpriteNode()
    var soundButton = SKSpriteNode()
    var rateButton = SKSpriteNode()
	var pauseButton = SKSpriteNode()
	var pauseTint = SKShapeNode()
	var pauseLabel = SKLabelNode()
	var touchStartLabel = SKLabelNode()
	 
    
    // title
    var titleImage = SKSpriteNode()
    
    
    // randomizer
    var randomizer: Int = 0
    var randomizer2: Int = 0
    
    var vortex = SKFieldNode()
    
    // boundary
    var boundary = SKSpriteNode()
    var textureAtlas = SKTextureAtlas()
    var contactable = false
	var expandingCircleNodes: Set<SKSpriteNode> = Set<SKSpriteNode>()
	let expandingCircleTexture = SKTexture(imageNamed: "boundary-2")
    
    var lastContactpoint = CGPoint(x: 0, y: 0)
    
    // energyMeter
    var energyMeter = SKSpriteNode()
    var energyMeterWidth = 0.0
    let depleteTime = 1.5
    let replenishTime = 3.0
    
    // ball
    var ball = SKShapeNode()
    
    
    // score label and best label
    var scoreLabel = SKLabelNode()
    var bestLabel = SKLabelNode()
    var score = 0
    
    var instructionLabel2 = SKLabelNode()
    
    
    var bestCrown = SKSpriteNode()
    var bestLabelCrown = SKLabelNode()
    
    var boundaryWidth: CGFloat!
    
    public enum Mask: UInt32 {
        case ball = 0
        case boundary = 1
        case ghost = 2
        
    }
    
    public enum GameState {
        case waitingToStart
        case running
        case startScreen
    }
    
    
    
    func createTextureAtlas () {
        let boundaryImage = #imageLiteral(resourceName: "boundary")
        let energyMeterImage = #imageLiteral(resourceName: "energyMeter")
        let pauseImage = #imageLiteral(resourceName: "pauseButton")
        let soundOnImage = #imageLiteral(resourceName: "soundOn")
        let muteImage = #imageLiteral(resourceName: "mute")
        let rateImage = #imageLiteral(resourceName: "ratingStar")
        let menuImage = #imageLiteral(resourceName: "menu")
        let keepinTitleImage = #imageLiteral(resourceName: "titleImage")
        let crownImage = #imageLiteral(resourceName: "crown")
        let hundredcrownImage = #imageLiteral(resourceName: "100crown")
        let leaderboardImage = #imageLiteral(resourceName: "leaderboard")
        let leaderboardNewImage = #imageLiteral(resourceName: "leaderboardNew")
        
        let textureDictionary = ["boundary" : boundaryImage, "boundary-1" : UIImage(named: "boundary-1"), "boundary-2": UIImage(named: "boundary-2"), "boundary-3" : UIImage(named: "boundary-3"),  "energyMeter" : energyMeterImage, "pauseButton" : pauseImage, "soundOn": soundOnImage, "rate" : rateImage, "mute" : muteImage, "menu" : menuImage, "keepinTitle" : keepinTitleImage, "crown" : crownImage, "100crown" : hundredcrownImage, "leaderboard": leaderboardImage, "leaderboardNew": leaderboardNewImage]
        
        textureAtlas = SKTextureAtlas(dictionary: textureDictionary)
    }
    
    func bestLabelSetup () {
        bestLabel.text = "best: " + String(KeyChain.highscore)
        bestLabel.fontSize = 40
        bestLabel.fontName = "Hiragino Sans"
        bestLabel.position = CGPoint(x: size.width / 2, y: -bestLabel.fontSize)
        bestLabel.name = "bestLabel"
        sequenceX = SKAction.sequence([fadeOut,fadeIn])
        self.addChild(bestLabel)
    }
    
    func titleSetup () {
        titleImage = SKSpriteNode(texture: textureAtlas.textureNamed("keepinTitle"), size: CGSize(width: size.width * 0.9, height: size.height / 6))
        titleImage.position = CGPoint(x: size.width / 2, y: size.height + titleImage.size.height)
        titleImage.name = "titleImage"
        
        // touchStartLabel
        touchStartLabel.text = "touch anywhere to start"
        touchStartLabel.fontColor = UIColor.white
        touchStartLabel.fontSize = 30
        touchStartLabel.fontName = "Hiragino Sans"
        touchStartLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.78)
        touchStartLabel.isHidden = true
        touchStartLabel.run(SKAction.repeatForever(sequenceX))
        
        
        self.addChild(touchStartLabel)
        self.addChild(titleImage)
    }
    
    
    
    func audioSetup () {
        audioTouch = SKAction.playSoundFileNamed("touch.wav", waitForCompletion: false)
        audioCongrats = SKAction.playSoundFileNamed("gong.wav", waitForCompletion: false)
        audioContact = SKAction.playSoundFileNamed("touch.wav", waitForCompletion: false)
        audioClick = SKAction.playSoundFileNamed("click.wav", waitForCompletion: false)
        audioDeath = SKAction.playSoundFileNamed("death.wav", waitForCompletion: false)
        audioUrAwesome = SKAction.playSoundFileNamed("urawesome.wav", waitForCompletion: false)
    }
    
    func newHighScore () {
		
		if (score >= 100) {
			UserDefaults.standard.set(true, forKey: "royalty")
			bestCrown.texture = textureAtlas.textureNamed("100crown")
		}
		KeyChain.highscore = score
		bestLabel.text = "best: " + String(score)
		bestLabelCrown.text = String(score)
		
        if !isMuted {
            if UserDefaults.standard.bool(forKey: "royalty") && !UserDefaults.standard.bool(forKey: "congratted")  {
                run(audioUrAwesome!)
                UserDefaults.standard.set(true, forKey: "congratted")
            } else {
                run(audioCongrats!)
            }
        }
        
        if let username = KeyChain.username {
			LeaderboardManager.newHighscore(username: username, highscore: KeyChain.highscore, success: nil)
		}
        
        let spark = SKEmitterNode(fileNamed: "newHighScore")
        let spark2 = SKEmitterNode(fileNamed: "newHighScore")
        
        spark?.position = CGPoint(x: 0, y: 0)
        spark2?.position = CGPoint(x: size.width, y: 0)
        spark?.emissionAngle = CGFloat(Double.pi * 0.45)
        spark2?.emissionAngle = CGFloat(Double.pi * 0.55)
        spark?.numParticlesToEmit = 1000
        spark2?.numParticlesToEmit = 1000
        
        let sequence = cutList()
        
        spark?.particleColorSequence = SKKeyframeSequence(keyframeValues: sequence, times: [0.1, 0.2, 0.3, 0.4, 0.5, 0.6])
        spark2?.particleColorSequence = SKKeyframeSequence(keyframeValues: sequence, times: [0.1, 0.2, 0.3, 0.4, 0.5, 0.6])
        
        setbestLabelPosition()
        
        self.addChild(spark!)
        self.addChild(spark2!)
        
        bestLabelCrown.text = String(KeyChain.highscore)
        bestLabelCrown.run(SKAction.repeatForever(sequenceX))
        bestCrown.run(SKAction.repeatForever(sequenceX))
        
        
    }
    // start: vortex strength = 1.5, restitution = 1.0, mass = 0.5, ld = 0.5
    // best: vortex strength = 2.3, restitution = 1.2, mass = 0.4, ld = 0.0
    
    func vortexSetup () {
        
        vortex = SKFieldNode.vortexField()
        vortex.name = "vortex"
        
        if randomizer == 1 {
            vortex.strength = 2.3
        } else {
            vortex.strength = -2.3
        }
        self.addChild(vortex)
    }
    
    func setbestLabelPosition() {
        let highscore = KeyChain.highscore
        if (highscore < 10) {
            bestLabelCrown.position = CGPoint(x: bestCrown.position.x + size.width / 17, y: bestCrown.position.y - size.width * 0.02)
            
        } else if (highscore < 100) {
            bestLabelCrown.position = CGPoint(x: bestCrown.position.x + size.width / 14, y: bestCrown.position.y - size.width * 0.02)
        } else {
            bestLabelCrown.position = CGPoint(x: bestCrown.position.x + size.width / 12, y: bestCrown.position.y - size.width * 0.02)
        }
        
    }
    
    
    
    func pauseSetup () {
        pauseButton = SKSpriteNode(texture: SKTexture(image: UIImage(named: "pauseButton")!), size: CGSize(width: size.width / 12, height: size.height / 20))
        
        pauseButton.name = "pauseButton"
        
        pauseButton.position = CGPoint(x: size.width * 0.08+xInset, y: size.height * 0.935)
        
        pauseLabel.text = "PAUSED"
        pauseLabel.fontName = "Hiragino Sans"
        
        pauseLabel.fontSize = 90
        pauseLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.48)
        pauseLabel.zPosition = 16
        
        
        pauseTint = SKShapeNode(rect: self.frame)
        pauseTint.strokeColor = UIColor.clear
        pauseTint.fillColor = UIColor.black
        pauseTint.alpha = 0.8
        pauseTint.zPosition = 15
        
        
        bestCrown.size = CGSize(width: size.width / 15, height: size.width / 17)
        bestCrown.position = CGPoint(x: size.width * 0.86-xInset, y: size.height * 0.935)
        
        let highscore = KeyChain.highscore
        
        if (highscore >= 100) {
            bestCrown.texture = textureAtlas.textureNamed("100crown")
        } else {
            bestCrown.texture = textureAtlas.textureNamed("crown")
        }
        self.addChild(bestCrown)
        
        bestLabelCrown.text = String(highscore)
        bestLabelCrown.fontColor = UIColor.white
        bestLabelCrown.fontName = "Hiragino Sans"
        bestLabelCrown.fontSize = size.width * 0.045
        self.addChild(bestLabelCrown)
        setbestLabelPosition()
        
        
        if (!UserDefaults.standard.bool(forKey: "instructed")) {
            if (GameScene.plays > 0) {
                UserDefaults.standard.set(true, forKey: "instructed")
            } else {
                instructionLabel2.fontName = "Hiragino-Sans Bold"
                instructionLabel2.text = "The circle blocks the ball while\nyou are holding down.You can\nhold down as long as your\nenergy bar hasn't depleted!"
                if #available(iOS 11.0, *) {
                    instructionLabel2.numberOfLines = 0
                } else {
                    instructionLabel2.text = ""
                }
                instructionLabel2.position = CGPoint(x: size.width / 2, y: size.height * 0.12)
                self.addChild(instructionLabel2)
            }
        }
        
        self.addChild(pauseButton)
    }
    
    func buttonSetup () {
        let buttonSize = CGSize(width: size.width / 8, height: size.width / 8)
        if UserDefaults.standard.bool(forKey: "seenLeaderboard") {
			leaderboardButton = SKSpriteNode(texture: textureAtlas.textureNamed("leaderboard"), size: buttonSize)
		} else {
			leaderboardButton = SKSpriteNode(texture: textureAtlas.textureNamed("leaderboardNew"), size: buttonSize)
		}
        
        if isMuted == false {
            soundButton = SKSpriteNode(texture: textureAtlas.textureNamed("soundOn"), size: buttonSize)
        } else {
            soundButton = SKSpriteNode(texture: textureAtlas.textureNamed("mute"), size: buttonSize)
        }
        rateButton = SKSpriteNode(texture: textureAtlas.textureNamed("rate"), size: buttonSize)
        
        leaderboardButton.name = "leaderboardButton"
        soundButton.name = "soundButton"
        rateButton.name = "rateButton"
        
        
        leaderboardButton.position = CGPoint(x: size.width / 4, y: -leaderboardButton.size.width)
        rateButton.position = CGPoint(x: size.width / 2, y: -leaderboardButton.size.width)
        soundButton.position = CGPoint(x: size.width * (3/4),y: -leaderboardButton.size.width)
        
        
        
        menuButton = SKSpriteNode(texture: textureAtlas.textureNamed("menu"), size: CGSize(width: size.width / 7, height: size.width / 7))
        menuButton.position = CGPoint(x: size.width / 2, y: size.height * 0.16)
        menuButton.zPosition = 16
        
        self.addChild(leaderboardButton)
        self.addChild(soundButton)
        self.addChild(rateButton)
        
        
        
        
    }
    
    func presentMenuFeatures (direction: String) {
        switch direction {
        case "UP":
            
            let startPositionYButton = -leaderboardButton.size.width
            let startPositionYBest = -bestLabel.fontSize
            let startPositionYTitle = size.height + titleImage.size.height
            
            let presentButton = SKAction.moveTo(y: startPositionYButton, duration: 0.5)
            let presentBest = SKAction.moveTo(y: startPositionYBest, duration: 0.5)
            let presentTitle = SKAction.moveTo(y: startPositionYTitle, duration: 0.5)
            
            self.touchStartLabel.isHidden = true
            
            leaderboardButton.run(presentButton)
            rateButton.run(presentButton)
            soundButton.run(presentButton)
            
            
            bestLabel.run(presentBest)
            titleImage.run(presentTitle, completion: {
                
                self.startGame()
                self.scoreLabel.removeAllActions()
                self.score = 0
                self.scoreLabel.text = String(self.score)
                self.scoreLabel.alpha = 1.0
                self.pauseSetup()
                
                
            })
            
            
        default:
            
            let endPositionYRateButton = size.height * 0.11
            let endPositionYShareButton = size.height * 0.13
            let endPositionYSoundButton = size.height * 0.13
            let endPositionYBest = size.height * 0.185
            let endPositionYTitle = size.height * 0.87
            
            let presentRateButton = SKAction.moveTo(y: endPositionYRateButton, duration: 0.5)
            let presentShareButton = SKAction.moveTo(y: endPositionYShareButton, duration: 0.5)
            let presentSoundButton = SKAction.moveTo(y: endPositionYSoundButton, duration: 0.5)
            let presentBest = SKAction.moveTo(y: endPositionYBest, duration: 0.5)
            let presentTitle = SKAction.moveTo(y: endPositionYTitle, duration: 0.5)
            
            
            
            leaderboardButton.run(presentShareButton)
            rateButton.run(presentRateButton)
            soundButton.run(presentSoundButton)
            
            
            bestLabel.run(presentBest)
            titleImage.run(presentTitle, completion: {self.touchStartLabel.isHidden = false
            })
            
            
        }
    }
    
    func scoreLabelSetup () {
        scoreLabel.text = String(score)
        scoreLabel.fontSize = 90
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.85)
        scoreLabel.fontName = "Hiragino Sans"
        score = 0
        scoreLabel.name = "scoreLabel"
        
        self.addChild(scoreLabel)
    }
    
    
    func energyMeterSetup () {
        canTouch = false
        energyMeterWidth = Double(size.width) * 0.9
        let energyMeterHeight = Double(size.height) / 60
        energyMeter = SKSpriteNode(texture: SKTexture(image:UIImage(named: "energyMeter")!), size: CGSize(width: 0, height: energyMeterHeight))
        energyMeter.position = CGPoint(x: size.width / 2, y: size.height * 0.8)
        energyMeter.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        energyMeter.zPosition = 10
        energyMeter.colorBlendFactor = 1.0
        energyMeter.color = transitionColor
        
        energyMeter.name = "energyMeter"

        let energyMeterFinalSize = CGSize(width: CGFloat(energyMeterWidth), height: CGFloat(energyMeterHeight))
        
        let expandAction = SKAction.resize(toWidth: energyMeterFinalSize.width, duration: 0.5)
        energyMeter.run(expandAction, completion: {self.canTouch = true})
        
        self.addChild(energyMeter)
        
        scoreLabel.run(SKAction.repeatForever(sequenceX))
    }
    
	func boundarySetup () {
		
		expandingCircleAction = SKAction.scale(to: CGSize(width: size.height * 3.0, height: size.height * 3.0), duration: 3.0)
		
		boundaryWidth = size.width * 0.9
		if currentAspect > GOLDEN_ASPECT {
			boundaryWidth *= 0.75
		}

        boundary = SKSpriteNode(texture: textureAtlas.textureNamed("boundary"), size: CGSize(width: boundaryWidth, height: boundaryWidth))
        
        
        boundary.position = CGPoint(x: size.width / 2, y: size.height / 2)
        let boundaryPhysicsPath = UIBezierPath(arcCenter: CGPoint(x: 0, y: 0), radius: boundaryWidth * 0.5 * 0.97, startAngle: 0, endAngle: CGFloat(Double.pi * 2.0), clockwise: true)
        boundary.physicsBody = SKPhysicsBody(edgeLoopFrom: boundaryPhysicsPath.cgPath)
        boundary.zPosition = 10
        boundary.colorBlendFactor = 1.0
        
        
        boundary.name = "boundary"
        
        // mask
        boundary.physicsBody?.categoryBitMask = Mask.boundary.rawValue
        
        
        self.addChild(boundary)
        
    }
    
    func ballSetup () {
        ball = SKShapeNode(circleOfRadius: boundary.size.width * GOLDEN_BALL_SHAPE_RATIO)
        ball.fillColor = UIColor.white
        ball.position = CGPoint(x: size.width / 2, y: size.height / 2)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: boundary.size.width * GOLDEN_BALL_PHYSICS_BODY_RATIO)
        ball.physicsBody?.affectedByGravity = false
        ball.physicsBody?.restitution = 1.2
        ball.physicsBody?.isDynamic = false
        ball.physicsBody?.mass = 0.5
        ball.zPosition = 11
        
    
        
        ball.name = "ball"
        
        // mask
        ball.physicsBody?.categoryBitMask = Mask.ball.rawValue
        
        self.addChild(ball)
        
    }
    
    func startGame() {
        
        if GameScene.plays > 1 {
            self.removeChildren(in: [instructionLabel2])
            UserDefaults.standard.set(true, forKey: "instructed")
        }
    
        
        NotificationCenter.default.post(Notification.init(name: Notification.Name("gameSceneTrue")))
        
        
        bestCrown.alpha = 1.0
        bestLabelCrown.alpha = 1.0
        
        if GameScene.plays == 8 {
            NotificationCenter.default.post(Notification.init(name: Notification.Name("playsReached")))
            GameScene.plays = 0
        }
        
        if firstPlay {
            NotificationCenter.default.post(Notification.init(name: Notification.Name("showBanner")))
            firstPlay = false
        }
    
        GameScene.plays += 1
        
        scene?.isPaused = false
        
        
        self.removeChildren(in: [leaderboardButton, rateButton, soundButton, titleImage, touchStartLabel, bestLabel, pauseLabel, vortex, energyMeter, ball])
    
        randomizer = Int(arc4random_uniform(2))
    
        energyMeterSetup()
        ballSetup()
        
        vortexSetup()
        randomVortex()
        
        scoreLabel.isHidden = false
        
        setContactable(contact: false)
        
        GameScene.gameState = GameState.waitingToStart
        
        if score > KeyChain.highscore  {
            newHighScore()
        }
        
    }
    
    func menu () {
        NotificationCenter.default.post(Notification.init(name: Notification.Name("gameSceneFalse")))
        firstPlay = true
        NotificationCenter.default.post(Notification.init(name: Notification.Name("hideBanner")))
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = UIColor.black
        GameScene.gameState = GameState.startScreen
        
        self.removeChildren(in: [leaderboardButton, rateButton, soundButton, titleImage, touchStartLabel, bestLabel, pauseLabel, vortex, energyMeter, ball, pauseTint, menuButton, pauseButton, bestCrown, bestLabelCrown, instructionLabel2])
        
        scoreLabel.isHidden = true
			
        bestLabelSetup()
        ballSetup()
        buttonSetup()
        titleSetup()
        
        GameScene.gameState = GameState.startScreen
        
        let boundaryShiftSequence = SKAction.sequence([SKAction.colorize(with: UIColor.blue, colorBlendFactor: 1.0, duration: 0.5), SKAction.colorize(with: UIColor.blue, colorBlendFactor: 1.0, duration: 0.5), SKAction.colorize(with: UIColor.cyan, colorBlendFactor: 1.0, duration: 0.5), SKAction.colorize(with: UIColor.green, colorBlendFactor: 1.0, duration: 0.5), SKAction.colorize(with: UIColor.yellow, colorBlendFactor: 1.0, duration: 0.5), SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: 0.5), SKAction.colorize(with: UIColor.magenta, colorBlendFactor: 1.0, duration: 0.5)])
        
        boundaryShiftSequence.speed = 0.5
        
        boundary.run(SKAction.repeatForever(boundaryShiftSequence))
        
        scene?.isPaused = false
        
        presentMenuFeatures(direction: "Down")
        
    }
    
    override func didMove(to view: SKView) {
		size.width = size.width * (currentAspect / GOLDEN_ASPECT)
		scene?.scaleMode = .aspectFill
        createTextureAtlas()
        boundarySetup()
        audioSetup()
        menu()
        scoreLabelSetup()
        scoreLabel.isHidden = true
    }

    func setContactable(contact: Bool) {
        
        if contact == false {
            contactable = false
            boundary.physicsBody?.collisionBitMask = Mask.ghost.rawValue
            boundary.physicsBody?.contactTestBitMask = Mask.ghost.rawValue
            ball.physicsBody?.collisionBitMask = Mask.ghost.rawValue
            ball.physicsBody?.contactTestBitMask = Mask.ghost.rawValue
            boundary.run(SKAction.colorize(with: UIColor.white, colorBlendFactor: 1.0, duration: 0.0))
            
            
        } else {
            contactable = true
            boundary.physicsBody?.collisionBitMask = Mask.ball.rawValue
            boundary.physicsBody?.contactTestBitMask = Mask.ball.rawValue
            ball.physicsBody?.collisionBitMask = Mask.boundary.rawValue
            ball.physicsBody?.contactTestBitMask = Mask.boundary.rawValue
            
        }
        
    }


    override func update(_ currentTime: TimeInterval) {
        
        if isBallOutside() {
            transitionColor = energyMeter.color
            if !isMuted {
                run(audioDeath!)
            }
            startGame()
        }
        
        expandingCircleNodes.forEach({ circleNode in circleNode.color = energyMeter.color })
 
        if energyMeter.size.width == 0.0 && GameScene.gameState != GameState.startScreen {
            setContactable(contact: false)
        }
        
        if contactable == true && GameScene.gameState != GameState.startScreen {
            boundary.color = energyMeter.color
        }
        scaleDamping()
    }

    func scaleDamping () {
        let currentSpeed = speed(vector: (ball.physicsBody?.velocity)!)
        if (currentSpeed > 1000) {
            ball.physicsBody?.linearDamping = 1.7
        } else {
            ball.physicsBody?.linearDamping = 0.0
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if canTouch {
            let touch = touches.first
            if touchInRange(button: pauseButton, location: (touch?.location(in: self))!) && !(scene?.isPaused)! && GameScene.gameState != GameState.startScreen {
                pause()
            } else if touchInRange(button: leaderboardButton, location: (touch?.location(in: self))!) && !(scene?.isPaused)! && self.children.contains(leaderboardButton) {
                leaderboard()
            } else if touchInRange(button: rateButton, location: (touch?.location(in: self))!) && !(scene?.isPaused)! && self.children.contains(rateButton) {
                rate()
            } else if touchInRange(button: soundButton, location: (touch?.location(in: self))!) && !(scene?.isPaused)! && self.children.contains(soundButton) {
                sound()
            } else if touchInRange(button: menuButton, location: (touch?.location(in: self))!) && self.children.contains(menuButton) {
                menu()
            } else if GameScene.gameState == GameState.startScreen {
                boundary.removeAllActions()
                transitionColor = myColors[Int(arc4random_uniform(UInt32(myColors.endIndex)))]
                boundary.color = UIColor.white
                presentMenuFeatures(direction: "UP")
			} else if scene!.isPaused {
                scene?.isPaused = false
                self.removeChildren(in: [pauseTint, pauseLabel, menuButton])
                self.addChild(pauseButton)
            } else {
                switch GameScene.gameState! {
                case .waitingToStart:
                    bestCrown.removeAllActions()
                    bestLabelCrown.removeAllActions()
                    bestCrown.alpha = 1.0
                    bestLabelCrown.alpha = 1.0
                    scoreLabel.removeAllActions()
                    scoreLabel.alpha = 1.0
                    score = 0
                    scoreLabel.text = String(score)
                    ball.physicsBody?.isDynamic = true
                    GameScene.gameState = GameState.running
                    break
                case .running:
                    if energyMeter.size.width != 0.0 {
                        setContactable(contact: true)
                        energyMeter.removeAction(forKey: "grow")
                        if canTouch {
                            energyMeter.run(SKAction.scaleX(by: 0, y: 1, duration: Double(energyMeter.size.width) / energyMeterWidth * depleteTime) , withKey: "shrink")
                        }
                    }
                    break
                default:
                    break
                }
                
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if canTouch {
            if (GameScene.gameState != GameState.startScreen) {
                setContactable(contact: false)
                energyMeter.removeAction(forKey: "shrink")
                if energyMeter.size.width != 0.0 {
                    energyMeter.run(SKAction.scaleX(by: CGFloat(energyMeterWidth) / energyMeter.size.width, y: 1, duration: (1 - (Double(energyMeter.size.width) / energyMeterWidth)) * replenishTime), withKey: "grow")
                }
            }
        }
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
		let expandingCircleNode = SKSpriteNode(texture: expandingCircleTexture, size: boundary.size)
		expandingCircleNode.position = boundary.position
		expandingCircleNode.colorBlendFactor = 1.0
		expandingCircleNode.color = boundary.color
		scene?.addChild(expandingCircleNode)
		expandingCircleNodes.update(with: expandingCircleNode)
		expandingCircleNode.run(expandingCircleAction, completion: {
			expandingCircleNode.removeFromParent()
			
			self.expandingCircleNodes.remove(expandingCircleNode)
		})
		
        if !(abs(contact.contactPoint.x - lastContactpoint.x) < (size.width / 250) && abs(contact.contactPoint.y - lastContactpoint.y) < (size.width / 250)) {
            if distance(contact.contactPoint, CGPoint(x: size.width / 2, y: size.height / 2)) <= boundaryWidth * 0.5 {
                score += 1
                scoreLabel.text = String(score)
                if !isMuted {
                    run(audioTouch!)
                }
                if Double(score).truncatingRemainder(dividingBy: 2) == 0.0 {
                    vortex.strength *= -1
                    randomVortex()
                    let colorChange = SKAction.colorize(with: myColors[colorIndex % myColors.endIndex], colorBlendFactor: 1.0, duration: 1.0)
                    colorIndex += 1
                    energyMeter.run(colorChange)
                }
            }
            lastContactpoint = contact.contactPoint
        } else {
            ball.physicsBody?.applyImpulse(CGVector(dx: contact.contactNormal.dx * 100, dy: contact.contactNormal.dy * 100))
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        alreadyContact = false
    }
    
    
    
    func isBallOutside() -> Bool {
        return ball.position.x < -10 || ball.position.x > size.width + 10 || ball.position.y < -10 || ball.position.y > size.height + 10
    }
    
    
    
    func pause () {
        if !isMuted {
            run(audioClick!)
            
            
        }
        scene?.isPaused = true
        self.removeChildren(in: [pauseButton])
        self.addChild(pauseTint)
        self.addChild(pauseLabel)
        self.addChild(menuButton)
    }
    
    func rate () {
		rateApp(appId: "id1273915355")
    }
    
	func leaderboard () {
        if !isMuted {
            run(audioClick!)
        }
        self.viewControllerDelegate?.presentLeaderboard()
        leaderboardButton.texture = textureAtlas.textureNamed("leaderboard")
    }
    
    func sound () {
        if !isMuted {
            run(audioClick!)
        }
        if isMuted == false {
            soundButton.texture = textureAtlas.textureNamed("mute")
            isMuted = true
        } else {
            soundButton.texture = textureAtlas.textureNamed("soundOn")
            isMuted = false
        }        
    }
    
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    
    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
    
    func speed(vector: CGVector) -> CGFloat {
        return sqrt(pow(vector.dx, 2.0) + pow(vector.dy, 2.0))
        
    }
    
    func randomVortex () {
        let x = random(min: -size.width / 2, max: size.width * 1.5)
        let y = sqrt(pow(size.width / 2, 2) - distance((self.view?.center)!, CGPoint(x: x, y: (self.view?.center.y)!)))
        
        vortex.position = CGPoint(x: x, y: y)
    }
    
    func touchInRange (button: SKSpriteNode, location: CGPoint) -> Bool {
        return distance(button.position, location) < button.size.width
    }
    
        
    func rateApp(appId: String) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else { return }
		UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
    
    func cutList () -> [UIColor] {
        let splitLocation = (colorIndex - 1) % myColors.endIndex
        
        let firstHalf = myColors[0..<splitLocation]
        let secondHalf = myColors[splitLocation..<myColors.endIndex]
        
        return Array(secondHalf + firstHalf)
        
    }
    
    
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
