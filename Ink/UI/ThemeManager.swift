//
//  ThemeManager.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import SwiftUI
import Combine

// MARK: - App Theme
public enum AppTheme: String {
    case dark = "dark"
    case light = "light"
}

// MARK: - Theme Manager
public class ThemeManager: ObservableObject {
    public static let shared = ThemeManager()
    
    @AppStorage("appTheme") public var appThemeRaw: String = AppTheme.dark.rawValue
    
    public var appTheme: AppTheme {
        AppTheme(rawValue: appThemeRaw) ?? .dark
    }
    
    public var preferredColorScheme: ColorScheme {
        appTheme == .dark ? .dark : .light
    }
    
    public func toggleTheme() {
        withAnimation(.easeInOut(duration: 0.25)) {
            appThemeRaw = appTheme == .dark ? AppTheme.light.rawValue : AppTheme.dark.rawValue
        }
        objectWillChange.send()
    }
    
    private init() {}
    
    // MARK: - Colors
    public struct Colors {
        
        // ─── DARK THEME (original charcoal sketch) ───
        public static let bgPrimaryDark      = Color(hex: "1C1C1E")
        public static let bgSecondaryDark    = Color(hex: "2C2C2E")
        public static let bgTertiaryDark     = Color(hex: "3A3A3C")
        public static let inkPrimaryDark     = Color(hex: "6B9FE8")
        public static let inkSecondaryDark   = Color(hex: "4A72B8")
        public static let errorInkDark       = Color(hex: "E8353B")
        public static let accentGoldDark     = Color(hex: "E8C840")
        public static let textPrimaryDark    = Color(hex: "E8DFC8")
        public static let bodyTextDark       = Color(hex: "E8DFC8")
        public static let victoryGreenDark   = Color(hex: "3db87a")
        
        // ─── LIGHT THEME (aged paper) ───
        public static let bgPrimaryLight     = Color(hex: "F4EDE0")
        public static let bgSecondaryLight   = Color(hex: "EDE2CF")
        public static let borderPrimaryLight = Color(hex: "D4B896")
        public static let accentRedLight     = Color(hex: "8B2020")
        public static let bodyTextLight      = Color(hex: "6B4C2A")
        public static let victoryGreenLight  = Color(hex: "2E7D4F")
        
        // ─── Semantic Accessors ───
        
        public static func bgPrimary(for scheme: ColorScheme) -> Color {
            scheme == .dark ? bgPrimaryDark : bgPrimaryLight
        }
        
        public static func bgSecondary(for scheme: ColorScheme) -> Color {
            scheme == .dark ? bgSecondaryDark : bgSecondaryLight
        }
        
        public static func inkPrimary(for scheme: ColorScheme) -> Color {
            scheme == .dark ? inkPrimaryDark : bodyTextLight
        }
        
        public static func inkSecondary(for scheme: ColorScheme) -> Color {
            scheme == .dark ? inkSecondaryDark : accentRedLight.opacity(0.28)
        }
        
        public static func errorInk(for scheme: ColorScheme) -> Color {
            scheme == .dark ? errorInkDark : accentRedLight
        }
        
        public static func accentRed(for scheme: ColorScheme) -> Color {
            scheme == .dark ? errorInkDark : accentRedLight
        }
        
        public static func bodyText(for scheme: ColorScheme) -> Color {
            scheme == .dark ? bodyTextDark : bodyTextLight
        }
        
        public static func victoryGreen(for scheme: ColorScheme) -> Color {
            scheme == .dark ? victoryGreenDark : victoryGreenLight
        }
        
        public static func ruledLineColor(for scheme: ColorScheme) -> Color {
            scheme == .dark
                ? inkSecondaryDark.opacity(0.25)
                : Color(red: 100/255, green: 65/255, blue: 20/255).opacity(0.12)
        }
        
        public static func marginLineColor(for scheme: ColorScheme) -> Color {
            scheme == .dark
                ? errorInkDark.opacity(0.40)
                : Color(red: 180/255, green: 60/255, blue: 60/255).opacity(0.28)
        }
        
        public static func progressBarFill(for scheme: ColorScheme) -> Color {
            scheme == .dark ? errorInkDark : accentRedLight
        }
        
        public static func progressBarBg(for scheme: ColorScheme) -> Color {
            scheme == .dark
                ? Color.white.opacity(0.08)
                : Color(hex: "6B4C2A").opacity(0.15)
        }
        
        public static func statNumber(for scheme: ColorScheme) -> Color {
            scheme == .dark ? errorInkDark : accentRedLight
        }
        
        public static func hintBoxBorder(for scheme: ColorScheme) -> Color {
            scheme == .dark
                ? inkPrimaryDark.opacity(0.40)
                : Color(hex: "6B4C2A").opacity(0.35)
        }
        
        public static func hintBoxText(for scheme: ColorScheme) -> Color {
            scheme == .dark ? textPrimaryDark : bodyTextLight
        }
        
        public static func toggleOnColor(for scheme: ColorScheme) -> Color {
            scheme == .dark ? errorInkDark : accentRedLight
        }
        
        public static func divider(for scheme: ColorScheme) -> Color {
            scheme == .dark
                ? Color.white.opacity(0.12)
                : Color(hex: "6B4C2A").opacity(0.18)
        }
        
        public static func sectionLabel(for scheme: ColorScheme) -> Color {
            scheme == .dark
                ? inkPrimaryDark.opacity(0.55)
                : Color(hex: "6B4C2A").opacity(0.45)
        }
        
        public static func achievementEarnedBorder(for scheme: ColorScheme) -> Color {
            accentRed(for: scheme)
        }
        
        public static func achievementEarnedBg(for scheme: ColorScheme) -> Color {
            scheme == .dark
                ? errorInkDark.opacity(0.12)
                : accentRedLight.opacity(0.08)
        }
        
        public static func achievementLockedBorder(for scheme: ColorScheme) -> Color {
            scheme == .dark
                ? Color.white.opacity(0.15)
                : Color(hex: "6B4C2A").opacity(0.25)
        }
        
        // Legacy light/dark specific aliases kept for back-compat
        public static let errorInkLight = Color(hex: "C0131A")
        public static let inkSecondaryLight = Color(hex: "2A5298")
    }
    
    // MARK: - Typography
    public struct Typography {
        public static func h1(for scheme: ColorScheme) -> Font {
            Font.custom("Caveat-Bold", size: 40, relativeTo: .largeTitle)
        }
        
        public static func h2(for scheme: ColorScheme) -> Font {
            Font.custom("Caveat-SemiBold", size: 28, relativeTo: .title)
        }
        
        public static func body(for scheme: ColorScheme) -> Font {
            Font.custom("SpecialElite-Regular", size: 16, relativeTo: .body)
        }
        
        public static func micro(for scheme: ColorScheme) -> Font {
            Font.custom("CourierPrime-Regular", size: 12, relativeTo: .caption)
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
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
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
    func handDrawnStroke(color: Color, lineWidth: CGFloat = 2.0, jitter: CGFloat = 1.0) -> some View {
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
    func sketchbookInkText(isError: Bool = false) -> some View {
        modifier(SketchbookInkTextModifier(isError: isError))
    }
}

public struct SketchbookInkTextModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let isError: Bool
    
    public func body(content: Content) -> some View {
        let color = isError
            ? ThemeManager.Colors.errorInk(for: colorScheme)
            : ThemeManager.Colors.inkPrimary(for: colorScheme)
        return content.foregroundColor(color)
    }
}
