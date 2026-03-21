//
//  ThemeManager.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import SwiftUI
import Combine

// MARK: - Theme Manager
public class ThemeManager: ObservableObject {
    public static let shared = ThemeManager()
    
    private init() {}
    
    // MARK: - Colors
    public struct Colors {
        // Light Mode
        public static let parchmentBackground = Color(red: 0.96, green: 0.94, blue: 0.89)
        public static let ballpointBlue = Color(red: 0.0, green: 0.0, blue: 0.55)
        public static let teacherRed = Color(red: 0.8, green: 0.1, blue: 0.1)
        public static let notebookLineBlue = Color(red: 0.6, green: 0.8, blue: 0.9).opacity(0.5)
        public static let notebookMarginRed = Color(red: 0.9, green: 0.4, blue: 0.4).opacity(0.6)
        
        // Dark Mode
        public static let charcoalPaper = Color(red: 0.15, green: 0.15, blue: 0.16)
        public static let graphiteGray = Color(red: 0.7, green: 0.7, blue: 0.75)
        public static let darkNotebookLine = Color(red: 0.3, green: 0.3, blue: 0.35).opacity(0.5)
        public static let darkNotebookMargin = Color(red: 0.6, green: 0.2, blue: 0.2).opacity(0.6)
    }
}

// MARK: - Hand-Drawn Helpers
public extension Shape {
    /// Applies a "jittery" displacement to simulate hand-drawn strokes
    func handDrawnStroke(color: Color, lineWidth: CGFloat = 2.0, jitter: CGFloat = 1.0) -> some View {
        // We simulate a doodle by combining layered dashed strokes with a slight offset
        self.stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round, dash: [lineWidth * 8, lineWidth * 1.5]))
            .overlay(
                self.stroke(color.opacity(0.6), lineWidth: lineWidth * 0.75)
                    .offset(x: jitter, y: jitter)
            )
            .overlay(
                self.stroke(color.opacity(0.4), lineWidth: lineWidth * 0.5)
                    .offset(x: -jitter, y: -jitter)
            )
    }
}

// MARK: - Global View Extensions
public extension View {
    /// Styles text with the appropriate ink color based on scheme and state.
    func sketchbookInkText(isError: Bool = false) -> some View {
        modifier(SketchbookInkTextModifier(isError: isError))
    }
}

public struct SketchbookInkTextModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let isError: Bool
    
    public func body(content: Content) -> some View {
        let ink: Color
        if isError {
            ink = colorScheme == .dark ? ThemeManager.Colors.teacherRed.opacity(0.8) : ThemeManager.Colors.teacherRed
        } else {
            ink = colorScheme == .dark ? ThemeManager.Colors.graphiteGray : ThemeManager.Colors.ballpointBlue
        }
        return content.foregroundColor(ink)
    }
}
