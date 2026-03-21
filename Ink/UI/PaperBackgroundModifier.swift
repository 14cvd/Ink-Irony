//
//  PaperBackgroundModifier.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import SwiftUI

public struct PaperBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let lineSpacing: CGFloat
    
    public init(lineSpacing: CGFloat = 36) {
        self.lineSpacing = lineSpacing
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            // Aged parchment / Dark Charcoal base paper color
            ThemeManager.Colors.bgPrimary(for: colorScheme)
                .ignoresSafeArea()
            
            // Notebook Lines Geometry
            GeometryReader { geometry in
                Path { path in
                    // Horizontal Lines (Light Blue)
                    let count = Int(geometry.size.height / lineSpacing)
                    for i in 0...count {
                        let y = CGFloat(i) * lineSpacing
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                }
                .stroke(
                    (colorScheme == .dark ? ThemeManager.Colors.inkSecondaryDark : ThemeManager.Colors.inkSecondaryLight).opacity(0.15),
                    lineWidth: ThemeManager.Layout.strokeHair
                )
                
                // Vertical Margin lines (Red margins characteristic of composition notebooks)
                Path { path in
                    let xOffset: CGFloat = 40
                    path.move(to: CGPoint(x: xOffset, y: 0))
                    path.addLine(to: CGPoint(x: xOffset, y: geometry.size.height))
                    
                    path.move(to: CGPoint(x: xOffset + 4, y: 0))
                    path.addLine(to: CGPoint(x: xOffset + 4, y: geometry.size.height))
                }
                .stroke(
                    ThemeManager.Colors.errorInk(for: colorScheme).opacity(0.3),
                    lineWidth: ThemeManager.Layout.strokeHair
                )
            }
            .ignoresSafeArea()
            
            // Render the rest of the app on top of the paper
            content
        }
    }
}

public extension View {
    // Kept as `sketchbookBackground` for drop-in replacement across the app
    func sketchbookBackground(lineSpacing: CGFloat = 36) -> some View {
        self.modifier(PaperBackgroundModifier(lineSpacing: lineSpacing))
    }
}
