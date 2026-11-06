//
//  InkFonts.swift
//  Ink
//
//  Three faces: Caveat (display: words, titles, buttons), Special Elite (the
//  teacher's voice only) and Courier Prime (UI and numbers). They are
//  registered from the bundle at launch (Ink/Resources/Fonts, licences next
//  to them). A face is used only for languages it fully covers; otherwise the
//  style falls back to a system face with the same role. Dynamic Type works
//  in both cases.
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

    private static var coverage: [String: Bool] = [:]

    /// True when the face is bundled and has every letter of the language, upper and lower case.
    /// Special Elite and Courier Prime have no Ə or Cyrillic, so az and ru use the role fallback
    /// instead of mixing faces inside a word.
    static func isAvailable(_ name: String, for language: Language) -> Bool {
        let key = name + "." + language.code
        if let known = coverage[key] { return known }
        var covered = false
        if let font = UIFont(name: name, size: 12) {
            let letters = String(language.alphabet)
            var units = Array((letters + letters.lowercased(with: language.locale)).utf16)
            var glyphs = [CGGlyph](repeating: 0, count: units.count)
            covered = CTFontGetGlyphsForCharacters(font as CTFont, &units, &glyphs, units.count)
        }
        coverage[key] = covered
        return covered
    }
}

extension Font {
    /// Handwritten display face: the word, titles, buttons.
    /// The rounded fallback is wider than Caveat, so it is drawn a little smaller.
    static func inkDisplay(_ size: CGFloat, relativeTo style: Font.TextStyle = .title) -> Font {
        InkFonts.isAvailable(InkFonts.display, for: L10n.language)
            ? .custom(InkFonts.display, size: size, relativeTo: style)
            : .system(size: scaled(size * 0.8, style), weight: .bold, design: .rounded)
    }

    /// Typewriter face for the teacher's lines and stamps.
    static func inkVoice(_ size: CGFloat = 15, relativeTo style: Font.TextStyle = .body) -> Font {
        InkFonts.isAvailable(InkFonts.voice, for: L10n.language)
            ? .custom(InkFonts.voice, size: size, relativeTo: style)
            : .system(size: scaled(size, style), design: .serif).italic()
    }

    /// Monospaced UI face for labels and numbers.
    static func inkUI(_ size: CGFloat = 14, weight: Font.Weight = .regular, relativeTo style: Font.TextStyle = .callout) -> Font {
        let name = weight == .bold || weight == .semibold ? InkFonts.uiBold : InkFonts.ui
        return InkFonts.isAvailable(name, for: L10n.language)
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

// Caveat's strokes run up to a fifth of an em past a letter's advance, and iOS clips
// a Text at its typographic width, so the last letter of a line loses its tail.
// A trailing space (a quarter em in Caveat) gives the tail room. Fallback faces need none.
// It is a no-break space, so it stays with the last word when the text wraps.
private let tailRoom = "\u{00A0}"

extension Text {
    init(handwritten text: String) {
        self.init(verbatim: InkFonts.isAvailable(InkFonts.display, for: L10n.language) ? text + tailRoom : text)
    }

    /// For short text centred in a fixed frame (word slots, grades, numbers): a space on
    /// each side keeps the letter centred and gives its tail room. Pair it with
    /// `.fixedSize()` so the spaces never shrink the letter.
    init(handwrittenCentered text: String) {
        self.init(verbatim: InkFonts.isAvailable(InkFonts.display, for: L10n.language) ? tailRoom + text + tailRoom : text)
    }
}

extension InkFonts {
    private static var inkWidths: [String: CGFloat] = [:]

    /// Width of the drawn strokes of `text` in the display face, as a fraction of the
    /// point size. Ж is about 0.92, I about 0.3.
    static func displayInkWidth(_ text: String) -> CGFloat {
        if let known = inkWidths[text] { return known }
        let font = UIFont(name: display, size: 100) ?? .systemFont(ofSize: 100, weight: .bold)
        let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: [.font: font]))
        let width = max(CTLineGetImageBounds(line, nil).width, CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))) / 100
        inkWidths[text] = width
        return width
    }
}

extension Label where Title == Text, Icon == Image {
    init(handwritten title: String, systemImage: String) {
        self.init { Text(handwritten: title) } icon: { Image(systemName: systemImage) }
    }
}

extension Button where Label == Text {
    init(handwritten title: String, action: @escaping () -> Void) {
        self.init(action: action) { Text(handwritten: title) }
    }
}
