//
//  InkFonts.swift
//  Ink
//
//  Three faces: Caveat (display: words, titles, buttons), Special Elite (the
//  teacher's voice only) and Courier Prime (UI and numbers). They are
//  registered from the bundle at launch, so dropping the .ttf files into
//  Ink/Resources/Fonts is enough. Until then every style falls back to a
//  system face with the same role, and Dynamic Type works in both cases.
//

import CoreText
import SwiftUI
import UIKit

enum InkFonts {
    static let display = "Caveat-Bold"
    static let voice = "SpecialElite-Regular"
    static let ui = "CourierPrime-Regular"
    static let uiBold = "CourierPrime-Bold"

    /// Registers every bundled .ttf and .otf for this process. Safe to call more than once.
    static func registerBundled() {
        for ext in ["ttf", "otf"] {
            for url in Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: nil) ?? [] {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
    }

    static func isAvailable(_ name: String) -> Bool {
        UIFont(name: name, size: 12) != nil
    }
}

extension Font {
    /// Handwritten display face: the word, titles, buttons.
    /// The rounded fallback is wider than Caveat, so it is drawn a little smaller.
    static func inkDisplay(_ size: CGFloat, relativeTo style: Font.TextStyle = .title) -> Font {
        InkFonts.isAvailable(InkFonts.display)
            ? .custom(InkFonts.display, size: size, relativeTo: style)
            : .system(size: scaled(size * 0.8, style), weight: .bold, design: .rounded)
    }

    /// Typewriter face for the teacher's lines and stamps.
    static func inkVoice(_ size: CGFloat = 15, relativeTo style: Font.TextStyle = .body) -> Font {
        InkFonts.isAvailable(InkFonts.voice)
            ? .custom(InkFonts.voice, size: size, relativeTo: style)
            : .system(size: scaled(size, style), design: .serif).italic()
    }

    /// Monospaced UI face for labels and numbers.
    static func inkUI(_ size: CGFloat = 14, weight: Font.Weight = .regular, relativeTo style: Font.TextStyle = .callout) -> Font {
        let name = weight == .bold || weight == .semibold ? InkFonts.uiBold : InkFonts.ui
        return InkFonts.isAvailable(name)
            ? .custom(name, size: size, relativeTo: style)
            : .system(size: scaled(size, style), weight: weight, design: .monospaced)
    }

    /// Keeps the design size and still follows Dynamic Type when a fallback face is used.
    private static func scaled(_ size: CGFloat, _ style: Font.TextStyle) -> CGFloat {
        UIFontMetrics(forTextStyle: style.uiKit).scaledValue(for: size)
    }
}

private extension Font.TextStyle {
    var uiKit: UIFont.TextStyle {
        switch self {
        case .largeTitle: .largeTitle
        case .title: .title1
        case .title2: .title2
        case .title3: .title3
        case .headline: .headline
        case .subheadline: .subheadline
        case .callout: .callout
        case .footnote: .footnote
        case .caption: .caption1
        case .caption2: .caption2
        default: .body
        }
    }
}
