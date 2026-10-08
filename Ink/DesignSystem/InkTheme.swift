//
//  InkTheme.swift
//  Ink
//
//  Design tokens: Paper (light) and Chalkboard (dark).
//  Colours are dynamic, so the theme follows the colour scheme with no extra code.
//

import SwiftUI
import UIKit

enum InkColor {
    static let paper = dynamic(light: 0xF7F0E3, dark: 0x1F2B27)
    static let sheet = dynamic(light: 0xFFFDF7, dark: 0x26352F)
    static let desk = dynamic(light: 0xEFE5D2, dark: 0x17211E)
    static let ink = dynamic(light: 0x1F2A44, dark: 0xEDEAE2)
    static let primaryFill = dynamic(light: 0x1F2A44, dark: 0xF4D35E)
    static let onPrimary = dynamic(light: 0xF7F0E3, dark: 0x1F2B27)
    static let teacher = dynamic(light: 0xC2362F, dark: 0xFF8A7A)
    static let correct = dynamic(light: 0x2C7A51, dark: 0x7FD8A6)
    static let onCorrect = dynamic(light: 0xFFFDF7, dark: 0x1F2B27)
    static let reward = dynamic(light: 0xFFE45C, dark: 0xF4D35E)
    static let onReward = dynamic(light: 0x1F2A44, dark: 0x1F2B27)
    static let inkDrop = dynamic(light: 0x2F5DA8, dark: 0x9CC8FF)
    static let secondary = dynamic(light: 0x5E5A54, dark: 0xA9B3AE)
    static let ghost = dynamic(light: 0x9A948A, dark: 0x6F7D77)
    static let ruledLine = dynamic(light: 0x2F5DA8, dark: 0xEDEAE2, lightAlpha: 0.16, darkAlpha: 0.05)
    static let marginLine = dynamic(light: 0xE06B5F, dark: 0xFF8A7A, lightAlpha: 0.55, darkAlpha: 0.25)
    /// Offset "ink" shadow under raised cards; the Chalkboard theme draws none.
    static let cardShadow = dynamic(light: 0x1F2A44, dark: 0x000000, lightAlpha: 1, darkAlpha: 0)
    static let buttonShadow = dynamic(light: 0xC2362F, dark: 0x000000, lightAlpha: 1, darkAlpha: 0)
    static let scrim = dynamic(light: 0x1F2A44, dark: 0x000000, lightAlpha: 0.35, darkAlpha: 0.55)

    // Book spines under the Doodle keep their colours in both themes.
    static let bookBlue = Color(hex: 0x2F5DA8)
    static let bookRed = Color(hex: 0xC2362F)
    static let bookYellow = Color(hex: 0xFFE45C)

    private static func dynamic(light: UInt32, dark: UInt32, lightAlpha: CGFloat = 1, darkAlpha: CGFloat = 1) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: dark, alpha: darkAlpha)
                : UIColor(hex: light, alpha: lightAlpha)
        })
    }
}

enum InkSpace {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 32
    static let screenMargin: CGFloat = 20
    static let marginLineX: CGFloat = 28
}

enum InkRadius {
    static let key: CGFloat = 9
    static let chip: CGFloat = 12
    static let button: CGFloat = 14
    static let card: CGFloat = 18
}

enum InkSize {
    static let minTarget: CGFloat = 44
    static let primaryButton: CGFloat = 56
    static let tabBar: CGFloat = 62
}

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(uiColor: UIColor(hex: hex))
    }
}

/// The player's theme choice. `system` follows the device; v1 stored "dark" or "light" under the same key.
enum InkThemeChoice: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
