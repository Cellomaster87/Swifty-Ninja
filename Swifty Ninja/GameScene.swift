//
//  GameScene.swift
//  Swifty Ninja
//
//  Created by Michele Galvagno on 01/05/2019.
//  Copyright © 2019 Michele Galvagno. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    // MARK: - Properties
    var gameScore: SKLabelNode!
    
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    var livesImages = [SKSpriteNode]()
    var lives = 3
    
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    
    var activeSlicePoints = [CGPoint]()
    var isSwooshSoundActive = false
    
    // MARK: - Scene management
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace // no alpha
        background.zPosition = -1
        addChild(background)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -6) // check this (less than the Earth default which is -9.81)
        physicsWorld.speed = 0.85 // everything happens at a slightly slower rate
        
        createScore()
        createLives()
        createSlices()
    }
    
    // MARK: - Touch methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // 1. Remove all existing points in the activeSlicePoints array, because we're starting fresh
        activeSlicePoints.removeAll(keepingCapacity: true)
        
        // 2. Get the touch location and add it to the activeSlicePoints array.
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        
        // 3. Call the redrawActiveSlice() method to clear the slice shapes.
        redrawActiveSlice()
        
        // 4. Remove any actions that are currently attached to the slice shapes. This is important if we are in the middle of a fadeOut(withDuration:) action
        activeSliceBG.removeAllActions()
        activeSliceFG.removeAllActions()
        
        // 5. Set both slice shapesto have an alpha value of 1 so they are fully visible
        activeSliceBG.alpha = 1
        activeSliceFG.alpha = 1
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        if !isSwooshSoundActive {
            playSwooshSound()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
    }
    
    // MARK: - Helper Methods
    func createScore() {
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        gameScore.position = CGPoint(x: 8, y: 8)
        score = 0
    }
    
    func createLives() {
        for i in 0 ..< 3 {
            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
            spriteNode.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720)
            addChild(spriteNode)
            
            livesImages.append(spriteNode)
        }
    }
    
    func createSlices() {
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2
        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth = 9
        addChild(activeSliceBG)
        
        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 3
        activeSliceFG.strokeColor = UIColor.white
        activeSliceFG.lineWidth = 5
        addChild(activeSliceFG)
    }
    
    func redrawActiveSlice() {
        // 1. if we have fewer than two points in our array, we don't have enough data to draw a line so it needs to clear the shapes and exit the method
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            
            return
        }
        
        // 2. if we have more than 12 slice points in our array, we need to remove the oldest ones until we have at most 12 — this stops the swipe from becoming too long.
        if activeSlicePoints.count > 12 {
            activeSlicePoints.removeFirst(activeSlicePoints.count - 12)
        }
        
        // 3. start the line at the position of the first swipe point, then go through each of the other drawing lines to each point
        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])
        
        for i in 1 ..< activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }
        
        // 4. update the slice shape paths so they get drawn using their design (line width and color)
        activeSliceBG.path = path.cgPath
        activeSliceFG.path = path.cgPath
    }
    
    func playSwooshSound() {
        isSwooshSoundActive = true
        
        let randomNumber = Int.random(in: 1...3)
        let soundName = "swoosh\(randomNumber).caf"
        
        let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        run(swooshSound) { [weak self] in
            self?.isSwooshSoundActive = false
        }
    }
}
