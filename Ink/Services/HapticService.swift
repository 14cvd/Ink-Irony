//
//  HapticService.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import UIKit
import CoreHaptics
import Combine

// MARK: - Haptic Service
public class HapticService: ObservableObject {
    public static let shared = HapticService()
    
    // CoreHaptics Engine for continuous textures (e.g. sketching pen across paper)
    private var engine: CHHapticEngine?
    
    // Standard UI Feedback Generators for crisp triggers
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    @Published public var isHapticsEnabled: Bool = true {
        didSet {
            if isHapticsEnabled {
                try? engine?.start()
                prepareHaptics()
            } else {
                engine?.stop()
            }
        }
    }
    
    private init() {
        prepareHaptics()
        setupCoreHaptics()
    }
    
    private func prepareHaptics() {
        selectionFeedback.prepare()
        impactLight.prepare()
        impactHeavy.prepare()
        notificationFeedback.prepare()
    }
    
    private func setupCoreHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("CoreHaptics is not supported on this device.")
            return
        }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            
            // Re-start the engine if it gets preempted by the system (e.g., incoming call)
            engine?.resetHandler = { [weak self] in
                do {
                    try self?.engine?.start()
                } catch {
                    print("Failed to restart the CHHapticEngine: \(error.localizedDescription)")
                }
            }
        } catch {
            print("CoreHaptics Engine Creation Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Public Triggers
    
    /// Basic selection switch mimicking a pen cap clicking or striking paper
    public func playPenStrike() {
        guard isHapticsEnabled else { return }
        selectionFeedback.selectionChanged()
        selectionFeedback.prepare() // Instantly re-prepare for rapid typing
    }
    
    /// Heavy thud representing the teacher's red scratch/loss of a life
    public func playErrorPulse() {
        guard isHapticsEnabled else { return }
        impactHeavy.impactOccurred(intensity: 1.0)
        
        // Double punch to emphasize mistake representing strict teacher ink scratch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.notificationFeedback.notificationOccurred(.error)
            self?.notificationFeedback.prepare()
        }
        impactHeavy.prepare()
    }
    
    /// Victory vibration sequence
    public func playSuccessPulse() {
        guard isHapticsEnabled else { return }
        notificationFeedback.notificationOccurred(.success)
        notificationFeedback.prepare()
    }
    
    /// Custom CoreHaptics pattern simulating a continuous sketch stroke over rough paper texture
    public func playSketchTexture(duration: TimeInterval = 0.5) {
        guard isHapticsEnabled, let engine = engine, CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            // Fallback for older devices handling simple light impacts
            impactLight.impactOccurred()
            return
        }
        
        // Continuous scraping/scratching paper sensation parameters
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
        
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: duration)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play continuous sketch texture: \(error.localizedDescription)")
        }
    }
}
