//
//  AudioService.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import AVFoundation
import Combine

// MARK: - Sound Effect Enum
public enum SoundEffect: String, CaseIterable {
    case pencilSnap = "pencil_snap"
    case paperTear = "paper_tear"
    case checkmark = "checkmark"
    case penScratch = "pen_scratch"
    case sfxCorrect = "sfx_correct"
    case sfxWrong = "sfx_wrong"
}

// MARK: - Audio Service
public class AudioService: ObservableObject {
    public static let shared = AudioService()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    
    // Toggles for user settings
    @Published public var isSoundEnabled: Bool = true
    
    private init() {
        configureAudioSession()
        preloadSounds()
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
    
    private func preloadSounds() {
        // Prepare AVAudioPlayers for exact timing during gameplay
        for effect in SoundEffect.allCases {
            // Note: In an actual App Bundle, these files must be added via Xcode target membership
            if let url = Bundle.main.url(forResource: effect.rawValue, withExtension: "mp3") {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    audioPlayers[effect.rawValue] = player
                } catch {
                    print("Failed to load sound \(effect.rawValue): \(error.localizedDescription)")
                }
            } else {
                // Sound file not found, silently ignore to avoid simulator warning loops
            }
        }
    }
    
    /// Plays the requested sound effect, restarting it if it is already playing for crisp feedback
    public func play(_ effect: SoundEffect) {
        guard isSoundEnabled else { return }
        
        if let player = audioPlayers[effect.rawValue] {
            if player.isPlaying {
                // Restart it for rapid typing responsiveness overlapping
                player.currentTime = 0
            }
            player.play()
        }
    }
}
