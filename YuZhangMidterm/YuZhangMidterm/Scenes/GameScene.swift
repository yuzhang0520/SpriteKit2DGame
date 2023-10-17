//
//  GameScene.swift
//  YuZhangMidterm
//
//  Created by Xcode User on 2020-10-24.
//  Copyright © 2020 Xcode User. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory{
    static let None : UInt32 = 0
    static let All : UInt32 = UInt32.max
    static let Bomb : UInt32 = 0b1
    static let Pokemon : UInt32 = 0b10
    static let Apple : UInt32 = 0b11
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    var background = SKSpriteNode(imageNamed: "background-hero.png")
    private var pikachu : SKSpriteNode?
    
    private var score : Int?
    let scoreIncrement = 10
    let timeIncrement = 1
    private var lblSocre : SKLabelNode?
    
    private var highScore : Int = UserDefaults.standard.integer(forKey: "highscore")
    private var lblHighScore : SKLabelNode?
    
    weak var viewController: UIViewController?
    weak var gameViewController: GameViewController?
    
    var timer = Timer()
    var gameTimer = 60
    private var lblGameTimer : SKLabelNode?
    
    override func didMove(to view: SKView) {
        
        background.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        background.zPosition = 1
        background.alpha = 0.7
        addChild(background)
        
        
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        scheduledTimerWithTimeInterval()
        
        pikachu = SKSpriteNode(imageNamed: "av-pikachu.png")
        pikachu?.alpha = 1.0
        pikachu?.zPosition = 2
        pikachu?.size = CGSize(width: 200.0, height: 196.0)
        pikachu?.position = CGPoint(x: 100.0, y: 200.0)
        pikachu?.name = "pikachu"
        addChild(pikachu!)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        pikachu?.physicsBody = SKPhysicsBody(circleOfRadius: (pikachu?.size.width)!/2)
        pikachu?.physicsBody?.isDynamic = true
        pikachu?.physicsBody?.categoryBitMask = PhysicsCategory.Pokemon
        pikachu?.physicsBody?.contactTestBitMask = PhysicsCategory.Bomb
        pikachu?.physicsBody?.collisionBitMask = PhysicsCategory.None
        pikachu?.physicsBody?.usesPreciseCollisionDetection = true
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addBomb), SKAction.wait(forDuration: 0.5), SKAction.run(addBomb), SKAction.wait(forDuration: 0.5),SKAction.run(addBomb), SKAction.wait(forDuration: 0.5),SKAction.run(addBomb), SKAction.wait(forDuration: 0.5),SKAction.run(addApple)])))
        
        score = 0
        self.lblSocre = self.childNode(withName: "//score") as? SKLabelNode
        self.lblSocre?.text = "Score: \(score!)"
        
        if(highScore >= score!){
            self.lblHighScore = self.childNode(withName: "//highScore") as? SKLabelNode
            self.lblHighScore?.text = "High Score: \(highScore)"
        }else{
            highScore = score!
            self.lblHighScore = self.childNode(withName: "//highScore") as? SKLabelNode
            self.lblHighScore?.text = "High Score: \(highScore)"
        }
        
        if let slabel = self.lblSocre{
            slabel.alpha = 0.0
            slabel.run(SKAction.fadeIn(withDuration: 2.0))
        }
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
        
    }
    
    @objc func updateCounting(){
        gameTimer -= 1
        if(gameTimer <= 0){
            gameover()
        }
        score = score! + timeIncrement
        self.lblSocre = self.childNode(withName: "//score") as? SKLabelNode
        self.lblSocre?.text = "Score: \(score!)"
        
        if let slabel = self.lblSocre{
            slabel.alpha = 0.0
            slabel.run(SKAction.fadeIn(withDuration: 1.0))
        }
        
        self.lblGameTimer = self.childNode(withName: "//gametimer") as? SKLabelNode
        self.lblGameTimer?.text = "\(gameTimer)"
        
        if(score! >= highScore){
            highScore = score!
            self.lblHighScore = self.childNode(withName: "//highScore") as? SKLabelNode
            self.lblHighScore?.text = "High Score: \(highScore)"
        }else{
            self.lblHighScore = self.childNode(withName: "//highScore") as? SKLabelNode
            self.lblHighScore?.text = "High Score: \(highScore)"
        }
        print(gameTimer)
    }
    
    func random() -> CGFloat{
        return CGFloat(Float(arc4random())/0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat{
        return random() * (max-min) + min
    }
    
    func addBomb(){
        let bomb = SKSpriteNode(imageNamed: "bomb.png")
        bomb.size = CGSize(width: 100, height: 98)
        bomb.zPosition = 2
        let actualX = random(min: bomb.size.width/2, max: size.width - bomb.size.width/2)
//        let actualY = random(min: bomb.size.height/2, max: size.height - bomb.size.height/2)
//        bomb.position = CGPoint(x: size.width + bomb.size.width/2, y: actualY)
        bomb.position = CGPoint(x: actualX, y: size.height + bomb.size.height/2)
        bomb.name = "bomb"
        
        addChild(bomb)
        
        bomb.physicsBody = SKPhysicsBody(rectangleOf: bomb.size)
        bomb.physicsBody?.isDynamic = true
        bomb.physicsBody?.categoryBitMask = PhysicsCategory.Bomb
        bomb.physicsBody?.contactTestBitMask = PhysicsCategory.Pokemon
        bomb.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        let actionMove = SKAction.move(to: CGPoint(x: actualX, y: -bomb.size.height/2), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        
        bomb.run(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    func addApple(){
        let apple = SKSpriteNode(imageNamed: "apple.png")
        apple.size = CGSize(width: 100, height: 100)
        apple.zPosition = 2
        let actualX = random(min: apple.size.width/2, max: size.width - apple.size.width/2)
        apple.position = CGPoint(x: actualX, y: size.height + apple.size.height/2)
        apple.name = "apple"
        
        addChild(apple)
        
        apple.physicsBody = SKPhysicsBody(rectangleOf: apple.size)
        apple.physicsBody?.isDynamic = true
        apple.physicsBody?.categoryBitMask = PhysicsCategory.Apple
        apple.physicsBody?.contactTestBitMask = PhysicsCategory.Pokemon
        apple.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        let actionMove = SKAction.move(to: CGPoint(x: actualX, y: -apple.size.height/2), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        
        apple.run(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    func pokemonDidCollideWithBomb(pokemon : SKSpriteNode, bomb: SKSpriteNode){
        print("Boom!")
        gameover()
        
    }
    
    func pokemonDidCollideWithApple(pokemon : SKSpriteNode, apple: SKSpriteNode){
        print("Yum!")
        
        score = score! + scoreIncrement
        self.lblSocre?.text = "Score: \(score!)"
        if let slabel = self.lblSocre {
            slabel.alpha = 0.0
            slabel.run(SKAction.fadeIn(withDuration: 2.0))
        }
    }
    
    func gameover(){
        self.speed = 0
        self.physicsWorld.speed = 0
        self.isPaused = true
        
        let pikachuSad = SKSpriteNode(imageNamed: "pikachu-sad.png")
        pikachuSad.alpha = 1.0
        pikachuSad.zPosition = 2
        pikachuSad.size = CGSize(width: 200.0, height: 200.0)
        pikachuSad.position = self.childNode(withName: "pikachu")!.position
        pikachuSad.name = "pikachuSad"
        addChild(pikachuSad)
        self.childNode(withName: "pikachu")?.removeFromParent()
        
        let bgWhite = SKSpriteNode(imageNamed: "bg-white.jpg")
        bgWhite.size = CGSize(width: 1334, height: 750)
        bgWhite.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        bgWhite.alpha = 0.6
        bgWhite.zPosition = 3
        addChild(bgWhite)
        
        let restart = SKSpriteNode(imageNamed: "restart.png")
        restart.size = CGSize(width: 200, height: 200)
        restart.zPosition = 4
        restart.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        restart.name = "restart"
        addChild(restart)

//        let btnHome = SKSpriteNode(imageNamed: "back-icon.png")
//        btnHome.size = CGSize(width: 200, height: 200)
//        btnHome.zPosition = 4
//        btnHome.position = CGPoint(x: frame.size.width/3 , y: frame.size.height/2)
//        btnHome.name = "home"
//        addChild(btnHome)
        
        
        if(score! > highScore){
            highScore = score!
        }
        
        timer.invalidate()
        UserDefaults.standard.set(highScore, forKey: "highscore")
        print("Game Over!")
    }
    
    func goToGameScene(){
//        if let view = self.view as! SKView? {
//            if let scene = SKScene(fileNamed: "GameScene") {
//                scene.scaleMode = .aspectFill
//                view.presentScene(scene)
//            }
//            view.ignoresSiblingOrder = true
//            view.showsFPS = true
//            view.showsNodeCount = true
//        }
        
        if let view = self.view as! SKView? {

            if let scene = GameScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // step 3 add this two line
                scene.viewController = gameViewController
                gameViewController?.dismiss(animated: true, completion: nil)
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
//        let newScene = GameScene(size: self.size)
//        newScene.scaleMode = self.scaleMode
//        let animation = SKTransition.fade(withDuration: 1.0)
//        self.view?.presentScene(newScene, transition: animation)
    }
    
    func goToHomePage(){
        gameViewController?.performSegue(withIdentifier: "home", sender: nil)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody : SKPhysicsBody
        var secondBody : SKPhysicsBody
        
        if(contact.bodyA.categoryBitMask == PhysicsCategory.Pokemon && contact.bodyB.categoryBitMask == PhysicsCategory.Bomb){
            firstBody = contact.bodyA
            secondBody = contact.bodyB
            pokemonDidCollideWithBomb(pokemon: firstBody.node as! SKSpriteNode, bomb: secondBody.node as! SKSpriteNode)
        }
        
        if(contact.bodyA.categoryBitMask == PhysicsCategory.Bomb && contact.bodyB.categoryBitMask == PhysicsCategory.Pokemon){
            firstBody = contact.bodyB
            secondBody = contact.bodyA
            pokemonDidCollideWithBomb(pokemon: firstBody.node as! SKSpriteNode, bomb: secondBody.node as! SKSpriteNode)
        }
            
        if(contact.bodyA.categoryBitMask == PhysicsCategory.Pokemon && contact.bodyB.categoryBitMask == PhysicsCategory.Apple){
            firstBody = contact.bodyA
            secondBody = contact.bodyB
            pokemonDidCollideWithApple(pokemon: firstBody.node as! SKSpriteNode, apple: secondBody.node as! SKSpriteNode)
        }
            
        if(contact.bodyA.categoryBitMask == PhysicsCategory.Apple && contact.bodyB.categoryBitMask == PhysicsCategory.Pokemon){
            firstBody = contact.bodyB
            secondBody = contact.bodyA
            pokemonDidCollideWithApple(pokemon: firstBody.node as! SKSpriteNode, apple: secondBody.node as! SKSpriteNode)
        }
        
    }
    
    func movePikachu(toPoint pos : CGPoint){
        let actionMoveRight = SKAction.moveTo(x: pos.x, duration: 0.1)
        pikachu?.run(SKAction.sequence([actionMoveRight]))
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
        movePikachu(toPoint: pos)
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
        movePikachu(toPoint: pos)
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self))
            let location = t.location(in: self)
            let node : SKNode = self.atPoint(location)
            if node.name == "restart" {
                print("restart")
                goToGameScene()
            }
//            if node.name == "home" {
//                print("home")
//                goToHomePage()
//            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
