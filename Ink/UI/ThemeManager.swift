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
        // Light — Pure White Paper Concept
        public static let bgPrimaryLight = Color(hex: "FFFFFF")
        public static let bgSecondaryLight = Color(hex: "F8F9FA")
        public static let bgTertiaryLight = Color(hex: "E9ECEF")
        public static let inkPrimaryLight = Color(hex: "1A3A6B")
        public static let inkSecondaryLight = Color(hex: "2A5298")
        public static let errorInkLight = Color(hex: "C0131A")
        public static let accentGoldLight = Color(hex: "C8A830")
        public static let graphiteLight = Color(hex: "4A4A4C")
        
        // Dark — Charcoal Sketch
        public static let bgPrimaryDark = Color(hex: "1C1C1E")
        public static let bgSecondaryDark = Color(hex: "2C2C2E")
        public static let bgTertiaryDark = Color(hex: "3A3A3C")
        public static let inkPrimaryDark = Color(hex: "6B9FE8")
        public static let inkSecondaryDark = Color(hex: "4A72B8")
        public static let errorInkDark = Color(hex: "E8353B")
        public static let accentGoldDark = Color(hex: "E8C840")
        public static let textPrimaryDark = Color(hex: "E8DFC8")
        
        // Semantic accessors
        public static func bgPrimary(for scheme: ColorScheme) -> Color {
            scheme == .dark ? bgPrimaryDark : bgPrimaryLight
        }
        
        public static func inkPrimary(for scheme: ColorScheme) -> Color {
            scheme == .dark ? inkPrimaryDark : inkPrimaryLight
        }
        
        public static func errorInk(for scheme: ColorScheme) -> Color {
            scheme == .dark ? errorInkDark : errorInkLight
        }
    }
    
    // MARK: - Typography
    public struct Typography {
        // Caveat Bold 700
        public static func h1(for scheme: ColorScheme) -> Font {
            customFont("Caveat-Bold", size: 40, weight: .bold, relativeTo: .largeTitle)
        }
        
        // Caveat SemiBold 600
        public static func h2(for scheme: ColorScheme) -> Font {
            customFont("Caveat-SemiBold", size: 28, weight: .semibold, relativeTo: .title)
        }
        
        // Special Elite 400
        public static func body(for scheme: ColorScheme) -> Font {
            customFont("SpecialElite-Regular", size: 16, weight: .regular, relativeTo: .body)
        }
        
        // Courier Prime 400
        public static func micro(for scheme: ColorScheme) -> Font {
            customFont("CourierPrime-Regular", size: 12, weight: .regular, relativeTo: .caption)
        }
        
        // Generic helper for custom fonts with system fallbacks
        private static func customFont(_ name: String, size: CGFloat, weight: Font.Weight, relativeTo style: Font.TextStyle) -> Font {
            // Using system fallbacks if custom fonts aren't bundled yet
            let fallbackName: String
            if name.contains("Caveat") {
                fallbackName = "Marker Felt"
            } else if name.contains("Special") {
                fallbackName = "Noteworthy"
            } else {
                fallbackName = "Courier"
            }
            
            // Using Specific Font Names which already encode weight
            return Font.custom(name, size: size, relativeTo: style)
        }
    }
    
    // MARK: - Spacing & Grid
    public struct Layout {
        public static let spacingXS: CGFloat = 4
        public static let spacingSM: CGFloat = 8
        public static let spacingMD: CGFloat = 16
        public static let spacingLG: CGFloat = 24
        public static let spacingXL: CGFloat = 32
        public static let spacingMajor: CGFloat = 48
        
        public static let cornerSM: CGFloat = 6
        public static let cornerMD: CGFloat = 12
        public static let cornerKey: CGFloat = 8
        public static let cornerBubble: CGFloat = 18
        
        public static let strokeHair: CGFloat = 1
        public static let strokeKey: CGFloat = 2
        public static let strokeBtn: CGFloat = 2.5
        public static let strokeBubble: CGFloat = 2
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
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
        let color = isError ? ThemeManager.Colors.errorInk(for: colorScheme) : ThemeManager.Colors.inkPrimary(for: colorScheme)
        return content.foregroundColor(color)
    }
}
