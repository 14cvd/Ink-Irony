//
//  DynamicKeyboardView.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import SwiftUI

public struct DynamicKeyboardView: View {
    let language: Language
    let guessedLetters: Set<Character>
    let onGuess: (Character) -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    // Adapts flexibly to exactly fit 26 English, 33 Russian, or 32 Azerbaijani characters beautifully
    private let columns = [
        GridItem(.adaptive(minimum: 40, maximum: 50), spacing: 8)
    ]
    
    public init(language: Language, guessedLetters: Set<Character>, onGuess: @escaping (Character) -> Void) {
        self.language = language
        self.guessedLetters = guessedLetters
        self.onGuess = onGuess
    }
    
    public var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            // Uniquely mapping Language.alphabet ensuring localized traits ("Ə", "Ş") render correctly locally!
            ForEach(language.alphabet, id: \.self) { char in
                let isGuessed = guessedLetters.contains(char)
                let inkColor = colorScheme == .dark ? ThemeManager.Colors.graphiteGray : ThemeManager.Colors.ballpointBlue
                let errorInkColor = colorScheme == .dark ? ThemeManager.Colors.teacherRed.opacity(0.8) : ThemeManager.Colors.teacherRed
                
                Button(action: {
                    onGuess(char)
                }) {
                    Text(String(char))
                        .font(.custom("Noteworthy", size: 24).bold())
                        .sketchbookInkText(isError: false)
                        .frame(width: 44, height: 44)
                        .overlay(
                            ZStack {
                                if !isGuessed {
                                    RoundedRectangle(cornerRadius: 8)
                                        .handDrawnStroke(color: inkColor, lineWidth: 1.5, jitter: 1.0)
                                } else {
                                    // Scratched out aggressively like an incorrect teacher's homework answer
                                    Path { path in
                                        path.move(to: CGPoint(x: 6, y: 6))
                                        path.addLine(to: CGPoint(x: 38, y: 38))
                                        path.move(to: CGPoint(x: 38, y: 6))
                                        path.addLine(to: CGPoint(x: 6, y: 38))
                                    }
                                    .handDrawnStroke(color: errorInkColor, lineWidth: 2.0, jitter: 1.5)
                                }
                            }
                        )
                }
                .disabled(isGuessed)
                .opacity(isGuessed ? 0.6 : 1.0)
            }
        }
        .padding()
    }
}
