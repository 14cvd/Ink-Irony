//
//  Teacher.swift
//  Ink
//
//  Ms. Irony: the avatar drawn in ink and her speech bubble.
//

import SwiftUI

enum TeacherMood: Equatable {
    case calm, annoyed, pleased
}

/// The teacher's face, drawn on a 58 × 58 grid and scaled to `size`.
struct TeacherAvatar: View {
    var mood: TeacherMood = .calm
    var size: CGFloat = 52

    var body: some View {
        Canvas { context, canvasSize in
            let s = canvasSize.width / 58
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
            let ink = GraphicsContext.Shading.color(InkColor.ink)
            let line = StrokeStyle(lineWidth: 2.2 * s, lineCap: .round, lineJoin: .round)

            // Face
            let face = Path(ellipseIn: CGRect(x: 7 * s, y: 9 * s, width: 44 * s, height: 44 * s))
            context.fill(face, with: .color(InkColor.sheet))
            context.stroke(face, with: ink, style: line)

            // Hair and bun
            var hair = Path()
            hair.move(to: p(10, 26))
            hair.addCurve(to: p(48, 26), control1: p(12, 8), control2: p(46, 6))
            hair.addCurve(to: p(10, 26), control1: p(42, 18), control2: p(20, 16))
            context.fill(hair, with: ink)
            context.fill(Path(ellipseIn: CGRect(x: 23 * s, y: 1 * s, width: 12 * s, height: 12 * s)), with: ink)

            // Glasses
            for x in [15.0, 31.0] {
                context.stroke(Path(ellipseIn: CGRect(x: x * s, y: 26 * s, width: 12 * s, height: 12 * s)), with: ink, style: StrokeStyle(lineWidth: 2 * s))
                context.fill(Path(ellipseIn: CGRect(x: (x + 4.5) * s, y: 31.5 * s, width: 3 * s, height: 3 * s)), with: ink)
            }
            var bridge = Path(); bridge.move(to: p(27, 32)); bridge.addLine(to: p(31, 32))
            context.stroke(bridge, with: ink, style: StrokeStyle(lineWidth: 2 * s))

            // Brows: the left one rises when she is annoyed
            var brows = Path()
            brows.move(to: p(15, mood == .annoyed ? 21 : 24)); brows.addLine(to: p(26, 25))
            brows.move(to: p(32, 22)); brows.addLine(to: p(43, 19))
            context.stroke(brows, with: ink, style: line)

            // Mouth in red pen
            var mouth = Path()
            switch mood {
            case .calm:
                mouth.move(to: p(23, 44)); mouth.addQuadCurve(to: p(36, 41), control: p(30, 46))
            case .annoyed:
                mouth.move(to: p(23, 45)); mouth.addQuadCurve(to: p(36, 44), control: p(30, 41))
            case .pleased:
                mouth.move(to: p(23, 43)); mouth.addQuadCurve(to: p(36, 43), control: p(30, 47))
            }
            context.stroke(mouth, with: .color(InkColor.teacher), style: line)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

/// The teacher's line in red typewriter ink. Announced to VoiceOver when it changes.
struct TeacherBubble: View {
    let text: String
    var tilt: Double = 0.6

    var body: some View {
        Text(text)
            .font(.inkVoice(15))
            .foregroundStyle(InkColor.teacher)
            .lineLimit(3)
            .minimumScaleFactor(0.8)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 13)
            .padding(.vertical, 9)
            .background(
                UnevenRoundedRectangle(topLeadingRadius: 16, bottomLeadingRadius: 4, bottomTrailingRadius: 16, topTrailingRadius: 16, style: .continuous)
                    .fill(InkColor.sheet)
            )
            .overlay(
                UnevenRoundedRectangle(topLeadingRadius: 16, bottomLeadingRadius: 4, bottomTrailingRadius: 16, topTrailingRadius: 16, style: .continuous)
                    .strokeBorder(InkColor.teacher, lineWidth: 2)
            )
            .rotationEffect(.degrees(tilt))
            .accessibilityLabel("Ms. Irony: \(text)")
            .accessibilityIdentifier("teacher.line")
    }
}

/// Avatar and bubble side by side, as on the Desk and in the game.
struct TeacherRow: View {
    let text: String
    var mood: TeacherMood = .calm
    var avatarSize: CGFloat = 52

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            TeacherAvatar(mood: mood, size: avatarSize)
            TeacherBubble(text: text)
                .id(text)
                .transition(.asymmetric(insertion: .scale(scale: 0.9, anchor: .leading).combined(with: .opacity), removal: .opacity))
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.7), value: text)
    }
}
