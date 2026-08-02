import SwiftUI
import SpriteKit
import AVFoundation
import AudioToolbox // For system sounds
import CoreHaptics // For advanced haptics

// MARK: - Explosion Types
enum ExplosionType: CaseIterable {
    case normal
    case peony
    case willow
    case ring
    case chrysanthemum
    case palm
    case crossette
    case dahlia
    case brocade
    case saturn
    case comet
    case spider
    case multiBreak
    case fountain
    case spiral
    case heart
    case star
    case diamond
}

// MARK: - Color Schemes
enum ColorScheme: CaseIterable {
    case classic
    case neon
    case pastel
    case monochrome
    case rainbow
    case fire
    case ocean
    case galaxy
    case valentine
    case halloween
    case christmas
    case patriotic
}

// MARK: - Weather Effects
enum WeatherEffect: CaseIterable {
    case none
    case rain
    case snow
    case wind
    case fog
}

// MARK: - Fireworks Scene
class FireworksScene: SKScene {
    // Game control states
    var fireworksPaused = false
    var shouldRestart = false
    var isSoundEnabled = true
    var isHapticsEnabled = true // New haptics toggle
    var countdownActive = false
    var countdownValue = 10
    
    // Haptics engine
    var hapticsEngine: CHHapticEngine?
    
    // Nodes
    var countdownLabel: SKLabelNode!
    var countdownTimer: Timer?
    
    // Particle textures
    let particleTextures = [
        SKTexture(imageNamed: "spark"),
        SKTexture(imageNamed: "star"),
        SKTexture(imageNamed: "circle")
    ]
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        scaleMode = .resizeFill
        
        // Setup countdown label
        countdownLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        countdownLabel.fontSize = 70
        countdownLabel.fontColor = .white
        countdownLabel.position = CGPoint(x: view.bounds.width/2, y: view.bounds.height/2)
        countdownLabel.zPosition = 10
        countdownLabel.isHidden = true
        addChild(countdownLabel)
        
        // Setup haptics engine
        setupHaptics()
        
        startFireworks()
    }
    
    func setupHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            hapticsEngine = try CHHapticEngine()
            try hapticsEngine?.start()
        } catch {
            print("Haptics engine error: \(error)")
        }
    }
    
    func startFireworks() {
        removeAllActions()
        removeAllChildren()
        addChild(countdownLabel) // Re-add after removeAllChildren
        
        // Launch fireworks at random intervals
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: Double.random(in: 0.1...0.8)),
                SKAction.run { [weak self] in
                    if !(self?.fireworksPaused ?? true) {
                        self?.launchSingleFirework()
                    }
                }
            ])
        ), withKey: "fireworks")
    }
    
    func launchSingleFirework() {
        // Ensure scene has valid size
        guard size.width > 100, size.height > 100 else { return }
        
        // Create firework rocket
        let rocket = SKSpriteNode(color: .white, size: CGSize(width: 2, height: 6))
        rocket.position = CGPoint(
            x: CGFloat.random(in: 50...size.width-50),
            y: -20
        )
        rocket.name = "rocket"
        addChild(rocket)
        
        // Add rocket trail (optional)
        if let trail = SKEmitterNode(fileNamed: "RocketTrail") {
            trail.targetNode = self
            rocket.addChild(trail)
        }
        
        // Target position (random in upper 2/3 of screen)
        let targetY = CGFloat.random(in: size.height/3...size.height-100)
        let targetPoint = CGPoint(
            x: CGFloat.random(in: 50...size.width-50),
            y: targetY
        )
        
        // Choose explosion type
        let explosionType = ExplosionType.allCases.randomElement()!
        
        // Animate rocket flight
        let flightDuration = TimeInterval(targetY / 300)
        rocket.run(SKAction.sequence([
            SKAction.move(to: targetPoint, duration: flightDuration),
            SKAction.run { [weak self] in
                rocket.removeFromParent()
                self?.createExplosion(ofType: explosionType, at: targetPoint)
            }
        ]))
    }
    
    func createExplosion(ofType type: ExplosionType, at position: CGPoint) {
        if isSoundEnabled {
            playExplosionSound()
        }
        
        if isHapticsEnabled {
            triggerHapticFeedback(for: type)
        }
        
        switch type {
        case .normal:
            createNormalExplosion(at: position)
        case .peony:
            createPeonyExplosion(at: position)
        case .willow:
            createWillowExplosion(at: position)
        case .ring:
            createRingExplosion(at: position)
        case .chrysanthemum:
            createChrysanthemumExplosion(at: position)
        case .palm:
            createPalmExplosion(at: position)
        case .crossette:
            createCrossetteExplosion(at: position)
        case .dahlia:
            createDahliaExplosion(at: position)
        case .brocade:
            createBrocadeExplosion(at: position)
        case .saturn:
            createSaturnExplosion(at: position)
        case .comet:
            createCometExplosion(at: position)
        case .spider:
            createSpiderExplosion(at: position)
        case .multiBreak:
            createMultiBreakExplosion(at: position)
        case .fountain:
            createFountainExplosion(at: position)
        case .spiral:
            createSpiralExplosion(at: position)
        case .heart:
            createHeartExplosion(at: position)
        case .star:
            createStarExplosion(at: position)
        case .diamond:
            createDiamondExplosion(at: position)
        }
    }
    
    func triggerHapticFeedback(for explosionType: ExplosionType) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        var intensity: Float = 0.7
        var sharpness: Float = 0.8
        var duration: Double = 0.3
        
        switch explosionType {
        case .peony:
            intensity = 0.9
            sharpness = 1.0
            duration = 0.5
        case .willow:
            intensity = 0.6
            sharpness = 0.5
            duration = 0.8
        case .ring:
            intensity = 0.8
            sharpness = 0.9
            duration = 0.4
        default:
            break
        }
        
        do {
            let pattern = try hapticPattern(intensity: intensity,
                                           sharpness: sharpness,
                                           duration: duration)
            try hapticsEngine?.start()
            
            // Create and start player
            let player = try hapticsEngine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)  // Start immediately
        } catch {
            print("Haptic pattern error: \(error)")
            // Fallback to simple vibration
            AudioServicesPlaySystemSound(1520)
        }
    }
    
    // UPDATED HAPTIC PATTERN CREATION
    func hapticPattern(intensity: Float, sharpness: Float, duration: Double) throws -> CHHapticPattern {
        let event = CHHapticEvent(
            eventType: .hapticContinuous,  // Changed to continuous
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: 0,  // Start immediately
            duration: duration  // Use specified duration
        )
        
        return try CHHapticPattern(events: [event], parameters: [])
    }
    
    func createNormalExplosion(at position: CGPoint) {
        let explosion = SKEmitterNode()
        explosion.particleTexture = particleTextures.randomElement() ?? SKTexture()
        explosion.particleBirthRate = 4000
        explosion.numParticlesToEmit = 1000
        explosion.particleLifetime = 1.5
        explosion.particleSpeed = 200
        explosion.particleSpeedRange = 50
        explosion.particleAlpha = 0.8
        explosion.particleAlphaSpeed = -0.7
        explosion.particleScale = 0.2
        explosion.particleScaleRange = 0.1
        explosion.particleScaleSpeed = -0.1
        explosion.particleRotationRange = .pi
        explosion.particleColorBlendFactor = 1
        explosion.particleColor = randomFireworkColor()
        explosion.position = position
        
        addAndRemoveEmitter(explosion)
    }
    
    func createPeonyExplosion(at position: CGPoint) {
        let explosion = SKEmitterNode()
        explosion.particleTexture = particleTextures.randomElement() ?? SKTexture()
        explosion.particleBirthRate = 5000
        explosion.numParticlesToEmit = 1500
        explosion.particleLifetime = 2.0
        explosion.particleSpeed = 180
        explosion.particleSpeedRange = 40
        explosion.particleAlpha = 0.9
        explosion.particleAlphaSpeed = -0.4
        explosion.particleScale = 0.25
        explosion.particleScaleRange = 0.15
        explosion.particleScaleSpeed = -0.05
        explosion.particleRotationRange = .pi
        explosion.particleColorBlendFactor = 1
        explosion.particleColor = randomFireworkColor()
        explosion.position = position
        
        // Peony effect - dense spherical burst
        explosion.emissionAngleRange = .pi * 2
        explosion.particlePositionRange = CGVector(dx: 5, dy: 5)
        
        addAndRemoveEmitter(explosion)
    }
    
    func createWillowExplosion(at position: CGPoint) {
        let explosion = SKEmitterNode()
        explosion.particleTexture = particleTextures.randomElement() ?? SKTexture()
        explosion.particleBirthRate = 3000
        explosion.numParticlesToEmit = 800
        explosion.particleLifetime = 4.0
        explosion.particleSpeed = 150
        explosion.particleSpeedRange = 30
        explosion.particleAlpha = 0.85
        explosion.particleAlphaSpeed = -0.2
        explosion.particleScale = 0.15
        explosion.particleScaleRange = 0.05
        explosion.particleScaleSpeed = -0.02
        explosion.particleRotationRange = .pi
        explosion.particleColorBlendFactor = 1
        explosion.particleColor = randomFireworkColor()
        explosion.position = position
        
        // Willow effect - particles fall slowly
        explosion.particleAction = SKAction.run {
            explosion.particlePositionRange.dx += 0.5
            explosion.particlePositionRange.dy += 0.5
            explosion.particleSpeed -= 1
        }
        
        // Add falling sparks
        let fallingSparks = SKEmitterNode()
        fallingSparks.particleTexture = particleTextures.first ?? SKTexture()
        fallingSparks.particleBirthRate = 200
        fallingSparks.particleLifetime = 3.0
        fallingSparks.particleSpeed = 50
        fallingSparks.particleAlpha = 0.7
        fallingSparks.particleAlphaSpeed = -0.5
        fallingSparks.particleScale = 0.1
        fallingSparks.particleColor = explosion.particleColor
        fallingSparks.position = position
        
        addAndRemoveEmitter(explosion)
        addAndRemoveEmitter(fallingSparks)
    }
    
    func createRingExplosion(at position: CGPoint) {
        let ringColor = randomFireworkColor()
        
        // Create multiple emitters in a ring pattern
        let ringSegments = 16
        let radius: CGFloat = 40.0
        
        for i in 0..<ringSegments {
            let angle = CGFloat(i) * (2 * .pi / CGFloat(ringSegments))
            let emitter = SKEmitterNode()
            emitter.particleTexture = particleTextures.randomElement() ?? SKTexture()
            emitter.particleBirthRate = 400
            emitter.numParticlesToEmit = 100
            emitter.particleLifetime = 1.2
            emitter.particleSpeed = 200
            emitter.particleAlpha = 0.8
            emitter.particleAlphaSpeed = -0.8
            emitter.particleScale = 0.15
            emitter.particleScaleRange = 0.05
            emitter.particleColor = ringColor
            emitter.position = position
            
            // Directional particles
            emitter.emissionAngle = angle
            emitter.emissionAngleRange = .pi / 8
            
            // Position offset for ring effect
            let xOffset = radius * cos(angle)
            let yOffset = radius * sin(angle)
            emitter.position = CGPoint(x: position.x + xOffset, y: position.y + yOffset)
            
            addAndRemoveEmitter(emitter)
        }
    }
    
    func addAndRemoveEmitter(_ emitter: SKEmitterNode) {
        addChild(emitter)
        emitter.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.run { emitter.particleBirthRate = 0 },
            SKAction.wait(forDuration: 3),
            SKAction.removeFromParent()
        ]))
    }
    
    // MARK: - Enhanced Color Management
    
    @State private var currentColorScheme: ColorScheme = .classic
    @State private var currentWeatherEffect: WeatherEffect = .none
    
    func randomFireworkColor() -> SKColor {
        return getColorFromScheme(currentColorScheme)
    }
    
    func getColorFromScheme(_ scheme: ColorScheme) -> SKColor {
        switch scheme {
        case .classic:
            let colors: [SKColor] = [
                .systemRed, .systemGreen, .systemBlue, .systemYellow,
                .systemOrange, .systemPurple, .systemPink, .systemTeal
            ]
            return colors.randomElement()!
            
        case .neon:
            let colors: [SKColor] = [
                SKColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0), // Hot pink
                SKColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0), // Cyan
                SKColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0), // Electric yellow
                SKColor(red: 0.5, green: 1.0, blue: 0.0, alpha: 1.0), // Electric green
                SKColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 1.0)  // Electric orange
            ]
            return colors.randomElement()!
            
        case .pastel:
            let colors: [SKColor] = [
                SKColor(red: 1.0, green: 0.7, blue: 0.8, alpha: 1.0), // Light pink
                SKColor(red: 0.7, green: 0.9, blue: 1.0, alpha: 1.0), // Light blue
                SKColor(red: 0.9, green: 1.0, blue: 0.7, alpha: 1.0), // Light green
                SKColor(red: 1.0, green: 0.9, blue: 0.7, alpha: 1.0), // Light orange
                SKColor(red: 0.9, green: 0.8, blue: 1.0, alpha: 1.0)  // Light purple
            ]
            return colors.randomElement()!
            
        case .monochrome:
            let grays: [SKColor] = [
                .white, .lightGray, .gray, .darkGray
            ]
            return grays.randomElement()!
            
        case .rainbow:
            let colors: [SKColor] = [
                .systemRed, .systemOrange, .systemYellow, .systemGreen,
                .systemBlue, .systemIndigo, .systemPurple
            ]
            return colors.randomElement()!
            
        case .fire:
            let colors: [SKColor] = [
                .systemRed, .systemOrange, .systemYellow,
                SKColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1.0), // Dark orange
                SKColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)  // Dark red
            ]
            return colors.randomElement()!
            
        case .ocean:
            let colors: [SKColor] = [
                .systemBlue, .systemTeal, SKColor.cyan,
                SKColor(red: 0.0, green: 0.3, blue: 0.8, alpha: 1.0), // Deep blue
                SKColor(red: 0.0, green: 0.6, blue: 0.6, alpha: 1.0)  // Teal blue
            ]
            return colors.randomElement()!
            
        case .galaxy:
            let colors: [SKColor] = [
                .systemPurple, .systemIndigo, .systemPink,
                SKColor(red: 0.3, green: 0.0, blue: 0.5, alpha: 1.0), // Deep purple
                SKColor(red: 0.5, green: 0.0, blue: 0.8, alpha: 1.0), // Violet
                .white // Stars
            ]
            return colors.randomElement()!
            
        case .valentine:
            let colors: [SKColor] = [
                .systemPink, .systemRed,
                SKColor(red: 1.0, green: 0.4, blue: 0.7, alpha: 1.0), // Hot pink
                .white
            ]
            return colors.randomElement()!
            
        case .halloween:
            let colors: [SKColor] = [
                .systemOrange, .black, .systemPurple,
                SKColor(red: 0.5, green: 0.2, blue: 0.0, alpha: 1.0) // Dark orange
            ]
            return colors.randomElement()!
            
        case .christmas:
            let colors: [SKColor] = [
                .systemRed, .systemGreen, .white,
                SKColor(red: 0.8, green: 0.8, blue: 0.0, alpha: 1.0) // Gold
            ]
            return colors.randomElement()!
            
        case .patriotic:
            let colors: [SKColor] = [
                .systemRed, .white, .systemBlue
            ]
            return colors.randomElement()!
        }
    }
    
    func applyWeatherEffect() {
        switch currentWeatherEffect {
        case .none:
            break
        case .rain:
            createRainEffect()
        case .snow:
            createSnowEffect()
        case .wind:
            applyWindEffect()
        case .fog:
            createFogEffect()
        }
    }
    
    func createRainEffect() {
        let rain = SKEmitterNode()
        rain.particleTexture = SKTexture(imageNamed: "spark") // Use small particles
        rain.particleBirthRate = 500
        rain.particleLifetime = 2.0
        rain.particleSpeed = 200
        rain.particleSpeedRange = 50
        rain.particleAlpha = 0.3
        rain.particleScale = 0.05
        rain.particleColor = SKColor.systemBlue
        rain.position = CGPoint(x: size.width / 2, y: size.height + 50)
        rain.particlePositionRange = CGVector(dx: size.width, dy: 0)
        rain.emissionAngle = -(.pi / 2) // Downward
        rain.emissionAngleRange = .pi / 6
        rain.yAcceleration = -300
        
        addChild(rain)
        
        // Remove rain after some time
        rain.run(SKAction.sequence([
            SKAction.wait(forDuration: 10.0),
            SKAction.removeFromParent()
        ]))
    }
    
    func createSnowEffect() {
        let snow = SKEmitterNode()
        snow.particleTexture = SKTexture(imageNamed: "circle")
        snow.particleBirthRate = 200
        snow.particleLifetime = 8.0
        snow.particleSpeed = 30
        snow.particleSpeedRange = 20
        snow.particleAlpha = 0.8
        snow.particleScale = 0.1
        snow.particleScaleRange = 0.05
        snow.particleColor = .white
        snow.position = CGPoint(x: size.width / 2, y: size.height + 50)
        snow.particlePositionRange = CGVector(dx: size.width, dy: 0)
        snow.emissionAngle = -(.pi / 2)
        snow.emissionAngleRange = .pi / 4
        snow.yAcceleration = -20
        
        // Add gentle swaying motion
        snow.particleAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.moveBy(x: 10, y: 0, duration: 1.0),
                SKAction.moveBy(x: -20, y: 0, duration: 2.0),
                SKAction.moveBy(x: 10, y: 0, duration: 1.0)
            ])
        )
        
        addChild(snow)
        
        snow.run(SKAction.sequence([
            SKAction.wait(forDuration: 15.0),
            SKAction.removeFromParent()
        ]))
    }
    
    func applyWindEffect() {
        // Add horizontal acceleration to all existing particles
        enumerateChildNodes(withName: "*") { node, _ in
            if let emitter = node as? SKEmitterNode {
                emitter.xAcceleration = CGFloat.random(in: -30...30)
            }
        }
    }
    
    func createFogEffect() {
        let fog = SKEmitterNode()
        fog.particleTexture = SKTexture(imageNamed: "circle")
        fog.particleBirthRate = 100
        fog.particleLifetime = 10.0
        fog.particleSpeed = 20
        fog.particleSpeedRange = 10
        fog.particleAlpha = 0.1
        fog.particleScale = 2.0
        fog.particleScaleRange = 1.0
        fog.particleColor = .lightGray
        fog.position = CGPoint(x: size.width / 2, y: 0)
        fog.particlePositionRange = CGVector(dx: size.width, dy: 0)
        fog.emissionAngleRange = .pi * 2
        fog.yAcceleration = 10
        
        addChild(fog)
        
        fog.run(SKAction.sequence([
            SKAction.wait(forDuration: 20.0),
            SKAction.removeFromParent()
        ]))
    }
    
    func playExplosionSound() {
        // Safe sound playback with fallback
        let explosionSounds = ["explosion1", "explosion2", "explosion3"]
        guard let soundFile = explosionSounds.randomElement() else {
            AudioServicesPlaySystemSound(1105) // Fallback system sound
            return
        }
        
        if let url = Bundle.main.url(forResource: soundFile, withExtension: "mp3") {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.volume = 0.3
                player.play()
            } catch {
                print("Error playing sound: \(error)")
                AudioServicesPlaySystemSound(1105) // Fallback system sound
            }
        } else {
            AudioServicesPlaySystemSound(1105) // Fallback system sound
        }
    }
    
    func playCountdownSound() {
        // Safe sound playback with fallback
        if let url = Bundle.main.url(forResource: "countdown", withExtension: "mp3") {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.volume = 0.5
                player.play()
            } catch {
                print("Error playing countdown sound: \(error)")
                AudioServicesPlaySystemSound(1103) // Fallback system sound
            }
        } else {
            AudioServicesPlaySystemSound(1103) // Fallback system sound
        }
    }
    
    func togglePause() {
        fireworksPaused.toggle()
        if fireworksPaused {
            removeAction(forKey: "fireworks")
        } else {
            startFireworks()
        }
    }
    
    func toggleSound() {
        isSoundEnabled.toggle()
    }
    
    func toggleHaptics() {
        isHapticsEnabled.toggle()
    }
    
    func startCountdown(seconds: Int) {
        // Stop any existing countdown
        countdownTimer?.invalidate()
        
        countdownValue = seconds
        countdownActive = true
        countdownLabel.isHidden = false
        
        if isSoundEnabled {
            playCountdownSound()
        }
        
        // Update label immediately
        countdownLabel.text = "\(countdownValue)"
        countdownLabel.setScale(1.0)
        countdownLabel.run(SKAction.scale(to: 1.2, duration: 0.1))
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.countdownValue -= 1
            
            if self.countdownValue > 0 {
                // Update display
                self.countdownLabel.text = "\(self.countdownValue)"
                self.countdownLabel.setScale(1.0)
                self.countdownLabel.run(SKAction.scale(to: 1.2, duration: 0.1))
                
                if self.isSoundEnabled {
                    self.playCountdownSound()
                }
            } else {
                // Countdown finished
                timer.invalidate()
                self.countdownLabel.text = "GO!"
                self.countdownLabel.run(SKAction.sequence([
                    SKAction.scale(to: 2.0, duration: 0.3),
                    SKAction.wait(forDuration: 1.0),
                    SKAction.fadeOut(withDuration: 0.5),
                    SKAction.run {
                        self.countdownLabel.isHidden = true
                        self.countdownLabel.alpha = 1.0
                        self.countdownLabel.setScale(1.0)
                    }
                ]))
                
                // Trigger special event
                self.triggerSpecialEvent()
                self.countdownActive = false
            }
        }
    }
    
    func triggerSpecialEvent() {
        // Create a grand finale with multiple fireworks
        let positions = [
            CGPoint(x: size.width * 0.2, y: size.height * 0.7),
            CGPoint(x: size.width * 0.5, y: size.height * 0.8),
            CGPoint(x: size.width * 0.8, y: size.height * 0.7)
        ]
        
        for (index, position) in positions.enumerated() {
            run(SKAction.sequence([
                SKAction.wait(forDuration: Double(index) * 0.3),
                SKAction.run { [weak self] in
                    self?.createExplosion(ofType: .peony, at: position)
                    self?.createExplosion(ofType: .ring, at: position)
                }
            ]))
        }
    }
    
    func restart() {
        shouldRestart = true
        startFireworks()
        shouldRestart = false
    }
    
    // MARK: - New Explosion Effects
    
    func createChrysanthemumExplosion(at position: CGPoint) {
        // Dense, spherical firework with lots of colors
        let colors = [SKColor.systemYellow, SKColor.systemOrange, SKColor.systemRed, SKColor.systemPink]
        
        for color in colors {
            let explosion = SKEmitterNode()
            explosion.particleTexture = particleTextures.randomElement() ?? SKTexture()
            explosion.particleBirthRate = 1500
            explosion.numParticlesToEmit = 600
            explosion.particleLifetime = 2.5
            explosion.particleSpeed = 160
            explosion.particleSpeedRange = 40
            explosion.particleAlpha = 0.85
            explosion.particleAlphaSpeed = -0.3
            explosion.particleScale = 0.3
            explosion.particleScaleRange = 0.1
            explosion.particleScaleSpeed = -0.08
            explosion.particleRotationRange = .pi
            explosion.particleColorBlendFactor = 1
            explosion.particleColor = color
            explosion.position = position
            explosion.emissionAngleRange = .pi * 2
            
            addAndRemoveEmitter(explosion)
        }
    }
    
    func createPalmExplosion(at position: CGPoint) {
        // Upward bursting effect like palm fronds
        let explosion = SKEmitterNode()
        explosion.particleTexture = particleTextures.randomElement() ?? SKTexture()
        explosion.particleBirthRate = 2000
        explosion.numParticlesToEmit = 800
        explosion.particleLifetime = 3.5
        explosion.particleSpeed = 120
        explosion.particleSpeedRange = 30
        explosion.particleAlpha = 0.9
        explosion.particleAlphaSpeed = -0.25
        explosion.particleScale = 0.2
        explosion.particleScaleRange = 0.08
        explosion.particleScaleSpeed = -0.04
        explosion.particleRotationRange = .pi / 4
        explosion.particleColorBlendFactor = 1
        explosion.particleColor = randomFireworkColor()
        explosion.position = position
        
        // Palm effect - mostly upward with some spread
        explosion.emissionAngle = .pi / 2 // Upward
        explosion.emissionAngleRange = .pi / 3
        explosion.yAcceleration = -50 // Gravity effect
        
        addAndRemoveEmitter(explosion)
    }
    
    func createCrossetteExplosion(at position: CGPoint) {
        // Multiple bursts from a central point
        let crossPoints = 8
        
        for i in 0..<crossPoints {
            let angle = CGFloat(i) * (2 * .pi / CGFloat(crossPoints))
            
            // Small delay for each burst
            run(SKAction.sequence([
                SKAction.wait(forDuration: Double(i) * 0.1),
                SKAction.run { [weak self] in
                    let explosion = SKEmitterNode()
                    explosion.particleTexture = self?.particleTextures.randomElement() ?? SKTexture()
                    explosion.particleBirthRate = 800
                    explosion.numParticlesToEmit = 200
                    explosion.particleLifetime = 1.8
                    explosion.particleSpeed = 180
                    explosion.particleSpeedRange = 20
                    explosion.particleAlpha = 0.8
                    explosion.particleAlphaSpeed = -0.5
                    explosion.particleScale = 0.18
                    explosion.particleScaleRange = 0.05
                    explosion.particleColor = self?.randomFireworkColor() ?? .white
                    explosion.position = position
                    explosion.emissionAngle = angle
                    explosion.emissionAngleRange = .pi / 8
                    
                    self?.addAndRemoveEmitter(explosion)
                }
            ]))
        }
    }
    
    func createDahliaExplosion(at position: CGPoint) {
        // Flower-like burst with petals
        let petalCount = 12
        let centerColor = randomFireworkColor()
        
        for i in 0..<petalCount {
            let angle = CGFloat(i) * (2 * .pi / CGFloat(petalCount))
            
            let petal = SKEmitterNode()
            petal.particleTexture = particleTextures.randomElement() ?? SKTexture()
            petal.particleBirthRate = 600
            petal.numParticlesToEmit = 150
            petal.particleLifetime = 2.2
            petal.particleSpeed = 140
            petal.particleSpeedRange = 25
            petal.particleAlpha = 0.85
            petal.particleAlphaSpeed = -0.4
            petal.particleScale = 0.22
            petal.particleScaleRange = 0.08
            petal.particleColor = centerColor
            petal.position = position
            petal.emissionAngle = angle
            petal.emissionAngleRange = .pi / 12
            
            addAndRemoveEmitter(petal)
        }
        
        // Add center burst
        let center = SKEmitterNode()
        center.particleTexture = particleTextures.randomElement() ?? SKTexture()
        center.particleBirthRate = 1000
        center.numParticlesToEmit = 300
        center.particleLifetime = 1.5
        center.particleSpeed = 80
        center.particleAlpha = 0.9
        center.particleAlphaSpeed = -0.6
        center.particleScale = 0.15
        center.particleColor = .white
        center.position = position
        center.emissionAngleRange = .pi * 2
        
        addAndRemoveEmitter(center)
    }
    
    func createBrocadeExplosion(at position: CGPoint) {
        // Glittering effect with trailing sparkles
        let explosion = SKEmitterNode()
        explosion.particleTexture = particleTextures.randomElement() ?? SKTexture()
        explosion.particleBirthRate = 3500
        explosion.numParticlesToEmit = 1200
        explosion.particleLifetime = 4.0
        explosion.particleSpeed = 130
        explosion.particleSpeedRange = 50
        explosion.particleAlpha = 1.0
        explosion.particleAlphaSpeed = -0.15
        explosion.particleScale = 0.12
        explosion.particleScaleRange = 0.08
        explosion.particleScaleSpeed = -0.02
        explosion.particleRotationRange = .pi * 2
        explosion.particleColorBlendFactor = 1
        explosion.particleColor = SKColor.systemYellow
        explosion.position = position
        explosion.emissionAngleRange = .pi * 2
        
        // Add glitter effect
        explosion.particleAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: 0.1),
                SKAction.run {
                    explosion.particleAlpha = CGFloat.random(in: 0.3...1.0)
                }
            ])
        )
        
        addAndRemoveEmitter(explosion)
    }
    
    func createSaturnExplosion(at position: CGPoint) {
        // Ring with trailing particles
        createRingExplosion(at: position)
        
        // Add orbital trails
        let orbitCount = 6
        for i in 0..<orbitCount {
            let angle = CGFloat(i) * (2 * .pi / CGFloat(orbitCount))
            let radius: CGFloat = 80
            
            let orbit = SKEmitterNode()
            orbit.particleTexture = particleTextures.randomElement() ?? SKTexture()
            orbit.particleBirthRate = 300
            orbit.numParticlesToEmit = 100
            orbit.particleLifetime = 3.0
            orbit.particleSpeed = 60
            orbit.particleAlpha = 0.7
            orbit.particleAlphaSpeed = -0.2
            orbit.particleScale = 0.1
            orbit.particleColor = randomFireworkColor()
            
            let orbitPath = CGPoint(
                x: position.x + radius * cos(angle),
                y: position.y + radius * sin(angle)
            )
            orbit.position = orbitPath
            
            addAndRemoveEmitter(orbit)
        }
    }
    
    func createCometExplosion(at position: CGPoint) {
        // Streaking effect with long trails
        let cometCount = 8
        
        for i in 0..<cometCount {
            let angle = CGFloat(i) * (2 * .pi / CGFloat(cometCount))
            
            let comet = SKEmitterNode()
            comet.particleTexture = particleTextures.randomElement() ?? SKTexture()
            comet.particleBirthRate = 400
            comet.numParticlesToEmit = 150
            comet.particleLifetime = 2.5
            comet.particleSpeed = 220
            comet.particleSpeedRange = 30
            comet.particleAlpha = 0.9
            comet.particleAlphaSpeed = -0.35
            comet.particleScale = 0.25
            comet.particleScaleRange = 0.1
            comet.particleScaleSpeed = -0.05
            comet.particleColor = randomFireworkColor()
            comet.position = position
            comet.emissionAngle = angle
            comet.emissionAngleRange = .pi / 16
            
            // Add trailing effect
            comet.particleAction = SKAction.sequence([
                SKAction.wait(forDuration: 0.2),
                SKAction.run {
                    comet.particleSpeed *= 0.8
                    comet.particleBirthRate *= 0.5
                }
            ])
            
            addAndRemoveEmitter(comet)
        }
    }
    
    func createSpiderExplosion(at position: CGPoint) {
        // Thin trails that spread out like spider legs
        let legCount = 12
        
        for i in 0..<legCount {
            let angle = CGFloat(i) * (2 * .pi / CGFloat(legCount))
            
            let leg = SKEmitterNode()
            leg.particleTexture = particleTextures.randomElement() ?? SKTexture()
            leg.particleBirthRate = 200
            leg.numParticlesToEmit = 80
            leg.particleLifetime = 3.0
            leg.particleSpeed = 160
            leg.particleSpeedRange = 10
            leg.particleAlpha = 0.8
            leg.particleAlphaSpeed = -0.25
            leg.particleScale = 0.08
            leg.particleScaleRange = 0.02
            leg.particleColor = randomFireworkColor()
            leg.position = position
            leg.emissionAngle = angle
            leg.emissionAngleRange = .pi / 24
            
            addAndRemoveEmitter(leg)
        }
    }
    
    func createMultiBreakExplosion(at position: CGPoint) {
        // Initial burst followed by secondary explosions
        createNormalExplosion(at: position)
        
        // Secondary bursts
        let secondaryCount = 6
        for i in 0..<secondaryCount {
            let delay = Double(i) * 0.3 + 1.0
            let angle = CGFloat(i) * (2 * .pi / CGFloat(secondaryCount))
            let distance: CGFloat = 100
            
            let secondaryPos = CGPoint(
                x: position.x + distance * cos(angle),
                y: position.y + distance * sin(angle)
            )
            
            run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.run { [weak self] in
                    self?.createNormalExplosion(at: secondaryPos)
                }
            ]))
        }
    }
    
    func createFountainExplosion(at position: CGPoint) {
        // Continuous upward spray
        let fountain = SKEmitterNode()
        fountain.particleTexture = particleTextures.randomElement() ?? SKTexture()
        fountain.particleBirthRate = 800
        fountain.numParticlesToEmit = 1000
        fountain.particleLifetime = 4.0
        fountain.particleSpeed = 100
        fountain.particleSpeedRange = 40
        fountain.particleAlpha = 0.9
        fountain.particleAlphaSpeed = -0.2
        fountain.particleScale = 0.15
        fountain.particleScaleRange = 0.05
        fountain.particleColor = randomFireworkColor()
        fountain.position = position
        fountain.emissionAngle = .pi / 2
        fountain.emissionAngleRange = .pi / 6
        fountain.yAcceleration = -80
        
        addAndRemoveEmitter(fountain)
    }
    
    func createSpiralExplosion(at position: CGPoint) {
        // Rotating spiral pattern
        let spiralArms = 4
        
        for arm in 0..<spiralArms {
            let baseAngle = CGFloat(arm) * (2 * .pi / CGFloat(spiralArms))
            
            for step in 0..<20 {
                let delay = Double(step) * 0.05
                let angle = baseAngle + CGFloat(step) * 0.3
                let distance = CGFloat(step) * 8
                
                run(SKAction.sequence([
                    SKAction.wait(forDuration: delay),
                    SKAction.run { [weak self] in
                        let spiral = SKEmitterNode()
                        spiral.particleTexture = self?.particleTextures.randomElement() ?? SKTexture()
                        spiral.particleBirthRate = 200
                        spiral.numParticlesToEmit = 30
                        spiral.particleLifetime = 1.5
                        spiral.particleSpeed = 80
                        spiral.particleAlpha = 0.8
                        spiral.particleAlphaSpeed = -0.5
                        spiral.particleScale = 0.12
                        spiral.particleColor = self?.randomFireworkColor() ?? .white
                        
                        let spiralPos = CGPoint(
                            x: position.x + distance * cos(angle),
                            y: position.y + distance * sin(angle)
                        )
                        spiral.position = spiralPos
                        spiral.emissionAngleRange = .pi * 2
                        
                        self?.addAndRemoveEmitter(spiral)
                    }
                ]))
            }
        }
    }
    
    func createHeartExplosion(at position: CGPoint) {
        // Heart-shaped particle pattern
        let heartPoints = 50
        let color = SKColor.systemPink
        
        for i in 0..<heartPoints {
            let t = CGFloat(i) / CGFloat(heartPoints) * 2 * .pi
            
            // Heart equation
            let x = 16 * pow(sin(t), 3)
            let y = 13 * cos(t) - 5 * cos(2*t) - 2 * cos(3*t) - cos(4*t)
            
            let delay = Double(i) * 0.02
            
            run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.run { [weak self] in
                    let heart = SKEmitterNode()
                    heart.particleTexture = self?.particleTextures.randomElement() ?? SKTexture()
                    heart.particleBirthRate = 150
                    heart.numParticlesToEmit = 20
                    heart.particleLifetime = 2.0
                    heart.particleSpeed = 50
                    heart.particleAlpha = 0.9
                    heart.particleAlphaSpeed = -0.4
                    heart.particleScale = 0.2
                    heart.particleColor = color
                    
                    let heartPos = CGPoint(
                        x: position.x + x * 3,
                        y: position.y + y * 3
                    )
                    heart.position = heartPos
                    heart.emissionAngleRange = .pi * 2
                    
                    self?.addAndRemoveEmitter(heart)
                }
            ]))
        }
    }
    
    func createStarExplosion(at position: CGPoint) {
        // Five-pointed star pattern
        let starPoints = 5
        let outerRadius: CGFloat = 80
        let innerRadius: CGFloat = 40
        
        for i in 0..<(starPoints * 2) {
            let angle = CGFloat(i) * (.pi / CGFloat(starPoints))
            let radius = (i % 2 == 0) ? outerRadius : innerRadius
            
            let starPos = CGPoint(
                x: position.x + radius * cos(angle - .pi/2),
                y: position.y + radius * sin(angle - .pi/2)
            )
            
            let star = SKEmitterNode()
            star.particleTexture = particleTextures.randomElement() ?? SKTexture()
            star.particleBirthRate = 300
            star.numParticlesToEmit = 80
            star.particleLifetime = 2.0
            star.particleSpeed = 100
            star.particleAlpha = 0.85
            star.particleAlphaSpeed = -0.4
            star.particleScale = 0.18
            star.particleColor = SKColor.systemYellow
            star.position = starPos
            star.emissionAngleRange = .pi * 2
            
            addAndRemoveEmitter(star)
        }
    }
    
    func createDiamondExplosion(at position: CGPoint) {
        // Diamond/rhombus shaped pattern
        let diamondPoints = [
            CGPoint(x: 0, y: 60),    // Top
            CGPoint(x: 60, y: 0),    // Right
            CGPoint(x: 0, y: -60),   // Bottom
            CGPoint(x: -60, y: 0)    // Left
        ]
        
        for (index, point) in diamondPoints.enumerated() {
            let delay = Double(index) * 0.1
            
            run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.run { [weak self] in
                    let diamond = SKEmitterNode()
                    diamond.particleTexture = self?.particleTextures.randomElement() ?? SKTexture()
                    diamond.particleBirthRate = 800
                    diamond.numParticlesToEmit = 200
                    diamond.particleLifetime = 2.5
                    diamond.particleSpeed = 120
                    diamond.particleSpeedRange = 30
                    diamond.particleAlpha = 0.9
                    diamond.particleAlphaSpeed = -0.35
                    diamond.particleScale = 0.2
                    diamond.particleScaleRange = 0.08
                    diamond.particleColor = SKColor.cyan
                    
                    let diamondPos = CGPoint(
                        x: position.x + point.x,
                        y: position.y + point.y
                    )
                    diamond.position = diamondPos
                    diamond.emissionAngleRange = .pi * 2
                    
                    self?.addAndRemoveEmitter(diamond)
                }
            ]))
        }
        
        // Center burst
        let center = SKEmitterNode()
        center.particleTexture = particleTextures.randomElement() ?? SKTexture()
        center.particleBirthRate = 1000
        center.numParticlesToEmit = 300
        center.particleLifetime = 1.8
        center.particleSpeed = 80
        center.particleAlpha = 1.0
        center.particleAlphaSpeed = -0.5
        center.particleScale = 0.15
        center.particleColor = .white
        center.position = position
        center.emissionAngleRange = .pi * 2
        
        addAndRemoveEmitter(center)
    }
}

func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

// MARK: - SwiftUI View
struct FireworksView: View {
    @State private var scene: FireworksScene = {
        let scene = FireworksScene()
        scene.scaleMode = .resizeFill
        return scene
    }()
    
    @State private var countdownSeconds: Int = 10
    @State private var showAdvancedControls = false
    @State private var selectedColorScheme: ColorScheme = .classic
    @State private var selectedWeatherEffect: WeatherEffect = .none
    
    var body: some View {
        ZStack(alignment: .bottom) {
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .onAppear {
                    scene.size = UIScreen.main.bounds.size
                }
                .onTapGesture {
                    hideKeyboard()
                }
            
            VStack(spacing: 20) {
                // Countdown Controls
                HStack {
                    TextField("Seconds", value: $countdownSeconds, formatter: NumberFormatter())
                        .frame(width: 50)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .padding(8)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(8)
                    
                    Button(action: {
                        scene.startCountdown(seconds: countdownSeconds)
                    }) {
                        Text("Start Countdown")
                            .padding(8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(15)
                
                // Control Buttons
                HStack(spacing: 30) {
                    ControlButton(
                        action: { scene.togglePause() },
                        icon: scene.fireworksPaused ? "play.fill" : "pause.fill"
                    )
                    
                    ControlButton(
                        action: { scene.toggleSound() },
                        icon: scene.isSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill"
                    )
                    
                    // New haptics toggle button
                    ControlButton(
                        action: { scene.toggleHaptics() },
                        icon: scene.isHapticsEnabled ? "hand.tap.fill" : "hand.tap"
                    )
                    
                    ControlButton(
                        action: { scene.restart() },
                        icon: "gobackward"
                    )
                }
            }
            .padding(.bottom, 40)
        }
    }
}

struct ControlButton: View {
    let action: () -> Void
    let icon: String
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Circle().fill(Color.black.opacity(0.5)))
                .shadow(radius: 10)
        }
    }
}

// MARK: - App Entry
@main
struct FireworksApp: App {
    var body: some Scene {
        WindowGroup {
            FireworksView()
        }
    }
}
