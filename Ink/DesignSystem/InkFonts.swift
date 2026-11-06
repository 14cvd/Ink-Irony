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
    /// Handwritten display face: the word, titles, buttons. Follows Dynamic Type.
    /// The rounded fallback is wider than Caveat, so it is drawn a little smaller.
    static func inkDisplay(_ size: CGFloat, relativeTo style: Font.TextStyle = .title) -> Font {
        InkFonts.isAvailable(InkFonts.display, for: L10n.language)
            ? Font(UIFontMetrics(forTextStyle: style.uiKit).scaledFont(for: InkFonts.caveat(size)))
            : .system(size: scaled(size * 0.8, style), weight: .bold, design: .rounded)
    }

    /// The display face at exactly `size`, for text inside a fixed frame (the word slots).
    static func inkDisplayFixed(_ size: CGFloat) -> Font {
        InkFonts.isAvailable(InkFonts.display, for: L10n.language)
            ? Font(InkFonts.caveat(size))
            : .system(size: size * 0.8, weight: .bold, design: .rounded)
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

// Caveat, as the app uses it:
// - Contextual alternates are off. With them on, SwiftUI measures a line narrower than it
//   draws, so wrapped titles lost their last word ("Gündəlik imtahan #…").
// - Strokes run up to a fifth of an em past a letter's advance (T, P, Ж, a final l or full
//   stop) and SwiftUI draws a Text only inside its own bounds, so `Text(handwritten:)` ends
//   the text with a no-break space that gives the last stroke room and stays with the last
//   word when it wraps. Fallback faces need none of this.

extension InkFonts {
    private static var caveats: [CGFloat: UIFont] = [:]

    static func caveat(_ size: CGFloat) -> UIFont {
        if let known = caveats[size] { return known }
        let descriptor = UIFontDescriptor(name: display, size: size).addingAttributes([
            .featureSettings: [[UIFontDescriptor.FeatureKey.type: kContextualAlternatesType,
                                UIFontDescriptor.FeatureKey.selector: kContextualAlternatesOffSelector]],
        ])
        let font = UIFont(descriptor: descriptor, size: size)
        caveats[size] = font
        return font
    }
}

private var needsTailRoom: Bool {
    InkFonts.isAvailable(InkFonts.display, for: L10n.language)
}

extension Text {
    /// Handwritten text: a title, a button label, a comment.
    init(handwritten text: String) {
        self.init(verbatim: needsTailRoom ? text + "\u{00A0}" : text)
    }

    /// Short handwritten text centred in a fixed frame (word slots, grades, numbers): room on
    /// both sides keeps it centred. Pair it with `.fixedSize()` so the room never shrinks it.
    init(handwrittenCentered text: String) {
        self.init(verbatim: needsTailRoom ? "\u{00A0}" + text + "\u{00A0}" : text)
    }
}

extension InkFonts {
    private struct Ink { let width: CGFloat; let centerShift: CGFloat }
    private static var inks: [String: Ink] = [:]

    private static func ink(_ text: String) -> Ink {
        if let known = inks[text] { return known }
        let font: UIFont = UIFont(name: display, size: 100) != nil ? caveat(100) : .systemFont(ofSize: 100, weight: .bold)
        let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: [.font: font]))
        let image = CTLineGetImageBounds(line, nil)
        let advance = CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))
        let value = Ink(width: max(image.width, advance) / 100, centerShift: (image.midX - advance / 2) / 100)
        inks[text] = value
        return value
    }

    /// Width of the drawn strokes of `text` in the display face, as a fraction of the
    /// point size. Ж is about 0.92, I about 0.3.
    static func displayInkWidth(_ text: String) -> CGFloat { ink(text).width }

    /// How far right of its advance centre the strokes sit, as a fraction of the point size.
    /// Caveat leans right, so a letter centred by advance looks off-centre; offset by minus this.
    static func displayInkCenterShift(_ text: String) -> CGFloat { ink(text).centerShift }
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
