//
//  TauntBubbleView.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import SwiftUI
import Combine

public struct TauntBubbleView: View {
    let text: String
    @Environment(\.colorScheme) private var colorScheme
    
    // Internal state to trigger the appearance and idle animations
    @State private var appearAnimation: Bool = false
    @State private var heartbeatScale: CGFloat = 1.0
    
    public init(text: String) {
        self.text = text
    }
    
    // Claude's Savage taunts are always written in the strict teacher's red ink
    private var inkColor: Color {
        ThemeManager.Colors.errorInk(for: colorScheme)
    }
    
    // The background paper color so it obscures the notebook lines behind it
    private var paperColor: Color {
        ThemeManager.Colors.bgPrimary(for: colorScheme)
    }
    
    public var body: some View {
        Text("\"\(text)\"")
            .font(ThemeManager.Typography.body(for: colorScheme).italic())
            .foregroundColor(inkColor)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(
                // Opaque background fill to block UI beneath
                SpeechBubbleShape()
                    .fill(paperColor)
                    // The angry jagged outline
                    .overlay(
                        SpeechBubbleShape()
                            .handDrawnStroke(color: inkColor, lineWidth: 2, jitter: 1.8)
                    )
            )
            // Subtly rotate randomly on start, and scale dynamically
            .rotationEffect(.degrees(appearAnimation ? CGFloat.random(in: -2...2) : 0))
            .scaleEffect(appearAnimation ? heartbeatScale : 0.8)
            .opacity(appearAnimation ? 1.0 : 0.0)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                    appearAnimation = true
                }
            }
            // A subtle repeating heartbeat representing the Savage AI's anger
            .onReceive(Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()) { _ in
                guard appearAnimation else { return }
                withAnimation(.easeInOut(duration: 0.15)) {
                    heartbeatScale = 1.03 // Inflate slightly
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        heartbeatScale = 1.0 // Return to normal
                    }
                }
            }
    }
}

// MARK: - Hand-Drawn Speech Bubble Path
public struct SpeechBubbleShape: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius: CGFloat = 16
        
        // Start top left
        path.move(to: CGPoint(x: rect.minX + radius, y: rect.minY))
        
        // Top edge: Slightly wavy
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY + CGFloat.random(in: -2...2)))
        
        // Top right corner
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + radius),
                          control: CGPoint(x: rect.maxX, y: rect.minY))
        
        // Right edge
        path.addLine(to: CGPoint(x: rect.maxX + CGFloat.random(in: -2...2), y: rect.maxY - radius))
        
        // Bottom right corner
        path.addQuadCurve(to: CGPoint(x: rect.maxX - radius, y: rect.maxY),
                          control: CGPoint(x: rect.maxX, y: rect.maxY))
        
        // Bottom edge leading to the tail
        let tailWidth: CGFloat = 25
        let tailHeight: CGFloat = 18
        let tailPos = rect.maxX * 0.65
        
        path.addLine(to: CGPoint(x: tailPos + tailWidth, y: rect.maxY + CGFloat.random(in: -2...2)))
        
        // Sharp, jagged tail pointing down and slightly right
        path.addLine(to: CGPoint(x: tailPos + (tailWidth * 0.7), y: rect.maxY + tailHeight))
        path.addLine(to: CGPoint(x: tailPos, y: rect.maxY))
        
        // Remaining bottom edge
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY + CGFloat.random(in: -2...2)))
        
        // Bottom left corner
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - radius),
                          control: CGPoint(x: rect.minX, y: rect.maxY))
        
        // Left edge
        path.addLine(to: CGPoint(x: rect.minX + CGFloat.random(in: -2...2), y: rect.minY + radius))
        
        // Top left corner
        path.addQuadCurve(to: CGPoint(x: rect.minX + radius, y: rect.minY),
                          control: CGPoint(x: rect.minX, y: rect.minY))
        
        return path
    }
}
