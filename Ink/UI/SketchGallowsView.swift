//
//  SketchGallowsView.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import SwiftUI

public struct SketchGallowsView: View {
    // Scaled from 0 (clean) to 8 (fully drawn hangman)
    let wrongGuesses: Int
    @Environment(\.colorScheme) private var colorScheme
    
    public init(wrongGuesses: Int) {
        self.wrongGuesses = wrongGuesses
    }
    
    // Natively adheres to the Sketchbook ink tokens
    private var inkColor: Color {
        ThemeManager.Colors.inkPrimary(for: colorScheme)
    }
    
    // Modular helper to draw and animate paths sequentially
    @ViewBuilder
    private func sketchPart(_ partNumber: Int) -> some View {
        GallowsPartShape(part: partNumber)
            // Hard trim prevents showing paths ahead of schedule
            .trim(from: 0, to: wrongGuesses >= partNumber ? 1.0 : 0.0)
            .handDrawnStroke(color: inkColor, lineWidth: 3, jitter: 1.5)
            // The magic that creates the "actively sketching" visual effect
            .animation(.easeInOut(duration: 0.5), value: wrongGuesses)
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 1. Base platform
                sketchPart(1)
                
                // 2. Vertical pole
                sketchPart(2)
                
                // 3. Top horizontal beam
                sketchPart(3)
                
                // 4. Rope
                sketchPart(4)
                
                // 5. Head (Circle)
                sketchPart(5)
                
                // 6. Body (Line)
                sketchPart(6)
                
                // 7. Arms (Path)
                sketchPart(7)
                
                // 8. Legs (Path)
                sketchPart(8)
            }
        }
    }
}

// MARK: - Individual Hangman Path Mathematical Drawer
public struct GallowsPartShape: Shape {
    let part: Int
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Logical scaffolding coordinates mapping to the GeometryReader dynamically
        let baseX: CGFloat = width * 0.2
        let baseY: CGFloat = height * 0.95
        let poleX: CGFloat = width * 0.35
        let topY: CGFloat = height * 0.1
        let ropeX: CGFloat = width * 0.65
        let ropeY: CGFloat = height * 0.2
        
        // Victim body proportions mapped logically down the rope
        let headRadius: CGFloat = 18
        let headCenterY = ropeY + headRadius
        let bodyStartY = headCenterY + headRadius
        let bodyEndY = bodyStartY + 50
        
        switch part {
        case 1: // Base platform with 3D/scratch marks
            path.move(to: CGPoint(x: baseX - 25, y: baseY))
            path.addLine(to: CGPoint(x: baseX + 45, y: baseY))
            
            path.move(to: CGPoint(x: baseX - 20, y: baseY + 5))
            path.addLine(to: CGPoint(x: baseX + 40, y: baseY + 5))
            
        case 2: // Vertical supporting pole
            path.move(to: CGPoint(x: poleX, y: baseY))
            path.addLine(to: CGPoint(x: poleX, y: topY))
            
        case 3: // Top horizontal beam & triangle bracket
            path.move(to: CGPoint(x: poleX, y: topY))
            path.addLine(to: CGPoint(x: ropeX + 15, y: topY))
            
            path.move(to: CGPoint(x: poleX, y: topY + 25))
            path.addLine(to: CGPoint(x: poleX + 25, y: topY))
            
        case 4: // Death Rope
            path.move(to: CGPoint(x: ropeX, y: topY))
            path.addLine(to: CGPoint(x: ropeX, y: ropeY))
            
            // The knotted tie point
            path.addEllipse(in: CGRect(x: ropeX - 4, y: ropeY - 6, width: 8, height: 8))
            
        case 5: // Head
            path.addArc(
                center: CGPoint(x: ropeX, y: headCenterY),
                radius: headRadius,
                startAngle: .degrees(-90),
                endAngle: .degrees(270),
                clockwise: false
            )
            
        case 6: // Torso Spine
            path.move(to: CGPoint(x: ropeX, y: bodyStartY))
            path.addLine(to: CGPoint(x: ropeX, y: bodyEndY))
            
        case 7: // Both Arms sharing one drawing cycle
            // Left Arm
            path.move(to: CGPoint(x: ropeX, y: bodyStartY + 12))
            path.addLine(to: CGPoint(x: ropeX - 25, y: bodyStartY + 35))
            
            // Right Arm
            path.move(to: CGPoint(x: ropeX, y: bodyStartY + 12))
            path.addLine(to: CGPoint(x: ropeX + 25, y: bodyStartY + 35))
            
        case 8: // Both Legs sharing the final drawing cycle
            // Left Leg
            path.move(to: CGPoint(x: ropeX, y: bodyEndY))
            path.addLine(to: CGPoint(x: ropeX - 22, y: bodyEndY + 40))
            
            // Right Leg
            path.move(to: CGPoint(x: ropeX, y: bodyEndY))
            path.addLine(to: CGPoint(x: ropeX + 22, y: bodyEndY + 40))
            
        default:
            break
        }
        
        return path
    }
}
