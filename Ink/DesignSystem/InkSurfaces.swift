//
//  InkSurfaces.swift
//  Ink
//
//  Notebook paper, cards and the strip of tape. Wobble and tilt are fixed per
//  view (never random in body), so nothing shimmers on re-render.
//

import SwiftUI

/// Ruled notebook paper with the red margin line.
struct NotebookPaper: View {
    var ruled = true
    var lineSpacing: CGFloat = 32

    var body: some View {
        InkColor.paper
            .overlay {
                if ruled {
                    Canvas { context, size in
                        var y = lineSpacing - 1
                        while y < size.height {
                            context.fill(Path(CGRect(x: 0, y: y, width: size.width, height: 1)), with: .color(InkColor.ruledLine))
                            y += lineSpacing
                        }
                        context.fill(Path(CGRect(x: InkSpace.marginLineX, y: 0, width: 2, height: size.height)), with: .color(InkColor.marginLine))
                    }
                }
            }
            .ignoresSafeArea()
            .accessibilityHidden(true)
    }
}

extension View {
    func notebookPaper(ruled: Bool = true) -> some View {
        background(NotebookPaper(ruled: ruled))
    }
}

/// A sheet of paper on the desk: border, optional offset ink shadow, optional tilt.
struct InkCardModifier: ViewModifier {
    var radius: CGFloat = InkRadius.card
    var raised = false
    var tilt: Double = 0
    var fill: Color = InkColor.sheet

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(fill)
                    .overlay(
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .strokeBorder(InkColor.ink, lineWidth: 2)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .fill(raised ? InkColor.cardShadow : .clear)
                            .offset(x: 4, y: 4)
                    )
            )
            .rotationEffect(.degrees(tilt))
    }
}

extension View {
    func inkCard(radius: CGFloat = InkRadius.card, raised: Bool = false, tilt: Double = 0, fill: Color = InkColor.sheet) -> some View {
        modifier(InkCardModifier(radius: radius, raised: raised, tilt: tilt, fill: fill))
    }
}

/// A strip of yellow tape that holds a card to the page.
struct Tape: View {
    var body: some View {
        Rectangle()
            .fill(InkColor.reward.opacity(0.75))
            .frame(width: 88, height: 22)
            .rotationEffect(.degrees(3))
            .accessibilityHidden(true)
    }
}

/// Small caps label used above sections.
struct Overline: View {
    let text: String
    var color: Color = InkColor.secondary

    var body: some View {
        Text(text.uppercased(with: L10n.locale))
            .font(.inkUI(12, weight: .bold, relativeTo: .caption))
            .tracking(2)
            .foregroundStyle(color)
    }
}

/// Hand-drawn underline under the logo.
struct Scribble: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + 2, y: rect.midY + 2))
        path.addCurve(
            to: CGPoint(x: rect.maxX * 0.68, y: rect.midY),
            control1: CGPoint(x: rect.maxX * 0.23, y: rect.minY),
            control2: CGPoint(x: rect.maxX * 0.45, y: rect.maxY)
        )
        path.addQuadCurve(to: CGPoint(x: rect.maxX - 2, y: rect.midY - 1), control: CGPoint(x: rect.maxX * 0.9, y: rect.midY + 1))
        return path
    }
}

struct InkLogo: View {
    var size: CGFloat = 36

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Ink & Irony")
                .font(.inkDisplay(size, relativeTo: .largeTitle))
                .foregroundStyle(InkColor.teacher)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .rotationEffect(.degrees(-2))
            Scribble()
                .stroke(InkColor.teacher, style: StrokeStyle(lineWidth: 2.2, lineCap: .round))
                .frame(width: size * 3.6, height: 10)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Ink & Irony")
        .accessibilityAddTraits(.isHeader)
    }
}
