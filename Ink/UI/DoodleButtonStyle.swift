//
//  DoodleButtonStyle.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import SwiftUI

public struct DoodleButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    let isDestructive: Bool
    
    public init(isDestructive: Bool = false) {
        self.isDestructive = isDestructive
    }
    
    // Selects the appropriate ink color natively
    private var inkColor: Color {
        if isDestructive {
            return colorScheme == .dark ? ThemeManager.Colors.teacherRed.opacity(0.8) : ThemeManager.Colors.teacherRed
        } else {
            return colorScheme == .dark ? ThemeManager.Colors.graphiteGray : ThemeManager.Colors.ballpointBlue
        }
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Noteworthy", size: 24).bold())
            .foregroundColor(configuration.isPressed ? (colorScheme == .dark ? .black : .white) : inkColor)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    // Dramatic Pen shading effect on press
                    if configuration.isPressed {
                        PenShadingShape()
                            .stroke(inkColor.opacity(0.8), lineWidth: 1.5)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .background(inkColor.opacity(0.3)) // Bleed
                    }
                    
                    // A roughly drawn rectangle border
                    RoundedRectangle(cornerRadius: 12)
                        // Make the line width thicker and jitterier when pressed to simulate bearing down on the pen
                        .handDrawnStroke(
                            color: inkColor,
                            lineWidth: configuration.isPressed ? 4.0 : 2.0,
                            jitter: configuration.isPressed ? 3.0 : 1.5
                        )
                        // Slight physical rotation when pressed
                        .rotationEffect(.degrees(configuration.isPressed ? CGFloat.random(in: -2...2) : 0))
                }
            )
            // Visually squash the button when tapped
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Hand-drawn scribble shading
// Generates a quick zig-zag "scribble" pattern to shade the button like a ballpoint pen
public struct PenShadingShape: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let step: CGFloat = 6.0
        var currentX = rect.minX - 20
        
        while currentX < rect.maxX + rect.height {
            path.move(to: CGPoint(x: currentX, y: rect.minY))
            path.addLine(to: CGPoint(x: currentX - rect.height, y: rect.maxY))
            currentX += step
        }
        
        return path
    }
}

public extension View {
    /// Applies the notebook-themed doodle button style.
    func doodleButtonStyle(isDestructive: Bool = false) -> some View {
        self.buttonStyle(DoodleButtonStyle(isDestructive: isDestructive))
    }
}
