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
    case stamp = "stamp"
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
            // v1 looked for .mp3 files that were never in the bundle, so the game was silent.
            // v2 ships synthesised .wav files (tools/make_sounds.py); other formats still work.
            let url = ["wav", "caf", "m4a", "mp3"].lazy.compactMap { Bundle.main.url(forResource: effect.rawValue, withExtension: $0) }.first
            if let url {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    audioPlayers[effect.rawValue] = player
                } catch {
                    print("Failed to load sound \(effect.rawValue): \(error.localizedDescription)")
                }
            } else {
                assertionFailure("Missing sound file: \(effect.rawValue)")
            }
        }
    }
    
    /// Plays the requested sound effect, restarting it if it is already playing for crisp feedback
    public func play(_ effect: SoundEffect) {
        // Respect the Settings toggle stored in UserDefaults
        let soundOn = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
        guard isSoundEnabled && soundOn else { return }
        
        if let player = audioPlayers[effect.rawValue] {
            if player.isPlaying {
                // Restart it for rapid typing responsiveness overlapping
                player.currentTime = 0
            }
            player.play()
        }
    }
}
