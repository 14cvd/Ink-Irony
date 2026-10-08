//
//  GallowsStage.swift
//  Ink
//
//  The v2 idea: ghost-to-ink gallows. Every remaining life is a faint pencil
//  part; each mistake the teacher's red pen inks one in. The Doodle stands on
//  a stack of books and reacts. Drawn on a 300 × 190 grid, scaled to fit.
//

import SwiftUI

enum DoodleMood: Equatable {
    case calm, nervous, panic, escaped, caught

    static func forState(livesLeft: Int, lives: Int, won: Bool, lost: Bool) -> DoodleMood {
        if won { return .escaped }
        if lost { return .caught }
        let spent = lives - livesLeft
        if livesLeft <= 1 || spent * 3 >= lives * 2 { return .panic }
        if spent * 3 >= lives { return .nervous }
        return .calm
    }
}

/// Maps the 300 × 190 design grid into any rect, aspect-fit and centred.
private struct StageGrid {
    let scale: CGFloat
    let origin: CGPoint

    init(_ rect: CGRect) {
        scale = min(rect.width / 300, rect.height / 190)
        origin = CGPoint(x: rect.minX + (rect.width - 300 * scale) / 2, y: rect.minY + (rect.height - 190 * scale) / 2)
    }

    func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: origin.x + x * scale, y: origin.y + y * scale)
    }

    func rect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect {
        CGRect(origin: p(x, y), size: CGSize(width: w * scale, height: h * scale))
    }
}

/// The eight strokes of the gallows, in drawing order.
private enum GallowsStroke: Int, CaseIterable {
    case baseTop, baseBottom, poleLow, poleHigh, beam, brace, rope, noose

    func add(to path: inout Path, _ g: StageGrid) {
        switch self {
        case .baseTop: path.move(to: g.p(30, 184)); path.addLine(to: g.p(120, 184))
        case .baseBottom: path.move(to: g.p(38, 179)); path.addLine(to: g.p(112, 179))
        case .poleLow: path.move(to: g.p(60, 182)); path.addLine(to: g.p(60, 102))
        case .poleHigh: path.move(to: g.p(60, 102)); path.addLine(to: g.p(60, 22))
        case .beam: path.move(to: g.p(58, 22)); path.addLine(to: g.p(198, 22))
        case .brace: path.move(to: g.p(60, 54)); path.addLine(to: g.p(92, 22))
        case .rope: path.move(to: g.p(190, 22)); path.addLine(to: g.p(190, 46))
        case .noose: path.addEllipse(in: g.rect(179, 76, 22, 8))
        }
    }

    /// Splits the eight strokes into `parts` groups, one per life, earlier groups larger.
    static func groups(parts: Int) -> [[GallowsStroke]] {
        let n = max(1, min(parts, allCases.count))
        var result: [[GallowsStroke]] = []
        var index = 0
        for i in 0..<n {
            let size = allCases.count / n + (i < allCases.count % n ? 1 : 0)
            result.append(Array(allCases[index..<index + size]))
            index += size
        }
        return result
    }
}

private struct GallowsPartShape: Shape {
    let strokes: [GallowsStroke]

    func path(in rect: CGRect) -> Path {
        let g = StageGrid(rect)
        var path = Path()
        for stroke in strokes { stroke.add(to: &path, g) }
        return path
    }
}

private enum DoodlePart {
    case head, eyes, mouth, sweat, spine, arms, legs
}

private struct DoodleShape: Shape {
    let part: DoodlePart
    let mood: DoodleMood

    func path(in rect: CGRect) -> Path {
        let g = StageGrid(rect)
        var path = Path()
        switch part {
        case .head:
            path.addEllipse(in: g.rect(174, 46, 32, 32))
        case .eyes:
            switch mood {
            case .calm, .nervous:
                path.move(to: g.p(184, 58)); path.addLine(to: g.p(184, 63))
                path.move(to: g.p(196, 58)); path.addLine(to: g.p(196, 63))
            case .panic:
                path.addEllipse(in: g.rect(180.5, 56.5, 7, 7))
                path.addEllipse(in: g.rect(192.5, 56.5, 7, 7))
            case .caught:
                path.move(to: g.p(181, 57)); path.addLine(to: g.p(187, 63))
                path.move(to: g.p(187, 57)); path.addLine(to: g.p(181, 63))
                path.move(to: g.p(193, 57)); path.addLine(to: g.p(199, 63))
                path.move(to: g.p(199, 57)); path.addLine(to: g.p(193, 63))
            case .escaped:
                path.move(to: g.p(181, 61)); path.addQuadCurve(to: g.p(187, 61), control: g.p(184, 56))
                path.move(to: g.p(193, 61)); path.addQuadCurve(to: g.p(199, 61), control: g.p(196, 56))
            }
        case .mouth:
            switch mood {
            case .calm: path.move(to: g.p(183, 68)); path.addQuadCurve(to: g.p(197, 68), control: g.p(190, 74))
            case .nervous: path.move(to: g.p(184, 70)); path.addLine(to: g.p(196, 70))
            case .panic: path.addEllipse(in: g.rect(186, 67, 8, 8))
            case .caught: path.move(to: g.p(183, 72)); path.addQuadCurve(to: g.p(197, 72), control: g.p(190, 66))
            case .escaped:
                path.move(to: g.p(181, 67)); path.addQuadCurve(to: g.p(199, 67), control: g.p(190, 79)); path.closeSubpath()
            }
        case .sweat:
            path.move(to: g.p(206, 50))
            path.addQuadCurve(to: g.p(206, 60), control: g.p(211, 57))
            path.addQuadCurve(to: g.p(206, 50), control: g.p(201, 57))
        case .spine:
            path.move(to: g.p(190, 78)); path.addLine(to: g.p(190, 118))
        case .arms:
            switch mood {
            case .panic, .escaped:
                path.move(to: g.p(190, 90)); path.addLine(to: g.p(171, 72))
                path.move(to: g.p(190, 90)); path.addLine(to: g.p(209, 72))
            case .caught:
                path.move(to: g.p(190, 90)); path.addLine(to: g.p(176, 112))
                path.move(to: g.p(190, 90)); path.addLine(to: g.p(204, 112))
            case .calm, .nervous:
                path.move(to: g.p(190, 90)); path.addLine(to: g.p(174, 108))
                path.move(to: g.p(190, 90)); path.addLine(to: g.p(206, 108))
            }
        case .legs:
            path.move(to: g.p(190, 118)); path.addLine(to: g.p(178, 150))
            path.move(to: g.p(190, 118)); path.addLine(to: g.p(202, 150))
        }
        return path
    }
}

private struct GroundShape: Shape {
    func path(in rect: CGRect) -> Path {
        let g = StageGrid(rect)
        var path = Path()
        path.move(to: g.p(20, 186)); path.addLine(to: g.p(290, 186))
        return path
    }
}

private struct BooksShape: Shape {
    let index: Int
    func path(in rect: CGRect) -> Path {
        let g = StageGrid(rect)
        let r = [g.rect(150, 150, 80, 11), g.rect(156, 161, 70, 11), g.rect(146, 172, 86, 12)][index]
        return Path(roundedRect: r, cornerRadius: 2 * g.scale)
    }
}

/// The whole stage: gallows parts (ghost or inked), books and the Doodle.
struct GallowsStage: View {
    let lives: Int
    let mistakes: Int
    let mood: DoodleMood

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { proxy in
            let lineScale = min(proxy.size.width / 300, proxy.size.height / 190)
            let groups = GallowsStroke.groups(parts: lives)
            ZStack {
                ground(lineScale)
                ForEach(groups.indices, id: \.self) { index in
                    let shape = GallowsPartShape(strokes: groups[index])
                    shape
                        .stroke(InkColor.ghost, style: StrokeStyle(lineWidth: 3 * lineScale, lineCap: .round, dash: [3 * lineScale, 6 * lineScale]))
                        .opacity(index < mistakes ? 0 : 0.8)
                    shape
                        .trim(from: 0, to: index < mistakes ? 1 : 0)
                        .stroke(InkColor.teacher, style: StrokeStyle(lineWidth: 3 * lineScale, lineCap: .round, lineJoin: .round))
                }
                books(lineScale)
                    .rotationEffect(.degrees(mood == .caught ? 9 : 0), anchor: .bottom)
                    .offset(x: mood == .caught ? 18 * lineScale : 0)
                doodle(lineScale)
                    .offset(x: mood == .escaped && !reduceMotion ? 70 * lineScale : 0, y: mood == .escaped && !reduceMotion ? -6 * lineScale : 0)
                    .rotationEffect(.degrees(mood == .escaped && !reduceMotion ? 10 : 0))
            }
            .animation(reduceMotion ? .easeOut(duration: 0.15) : .timingCurve(0.2, 0.8, 0.2, 1, duration: 0.45), value: mistakes)
            .animation(reduceMotion ? nil : .spring(response: 0.6, dampingFraction: 0.55), value: mood)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(L10n.livesLeft(lives - mistakes, of: lives)))
        .accessibilityIdentifier("game.stage")
    }

    private func ground(_ s: CGFloat) -> some View {
        GroundShape().stroke(InkColor.secondary, style: StrokeStyle(lineWidth: 1.5 * s, lineCap: .round))
    }

    private func books(_ s: CGFloat) -> some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                BooksShape(index: index)
                    .fill([InkColor.bookBlue, InkColor.bookRed, InkColor.bookYellow][index])
                    .overlay(BooksShape(index: index).stroke(InkColor.ink, lineWidth: 2 * s))
            }
        }
    }

    private func doodle(_ s: CGFloat) -> some View {
        let line = StrokeStyle(lineWidth: 2.6 * s, lineCap: .round, lineJoin: .round)
        return ZStack {
            DoodleShape(part: .head, mood: mood).fill(InkColor.sheet)
            DoodleShape(part: .head, mood: mood).stroke(InkColor.ink, style: line)
            DoodleShape(part: .eyes, mood: mood).stroke(InkColor.ink, style: StrokeStyle(lineWidth: 2.2 * s, lineCap: .round))
            DoodleShape(part: .mouth, mood: mood).stroke(InkColor.ink, style: StrokeStyle(lineWidth: 2.2 * s, lineCap: .round, lineJoin: .round))
            DoodleShape(part: .sweat, mood: mood)
                .fill(InkColor.inkDrop)
                .opacity(mood == .nervous || mood == .panic ? 1 : 0)
            DoodleShape(part: .spine, mood: mood).stroke(InkColor.ink, style: line)
            DoodleShape(part: .arms, mood: mood).stroke(InkColor.ink, style: line)
            DoodleShape(part: .legs, mood: mood).stroke(InkColor.ink, style: line)
        }
    }
}
