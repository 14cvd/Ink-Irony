//
//  SplashView.swift
//  Ink
//
//  Cold-launch moment, about 1.3 s: the page is ruled, a drop of ink lands,
//  and the pen writes the name. A tap skips it; Reduce Motion gets a short fade.
//

import SwiftUI

struct SplashView: View {
    let finish: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var ruled: CGFloat = 0
    @State private var dropFallen = false
    @State private var blot: CGFloat = 0
    @State private var written: CGFloat = 0
    @State private var underlined: CGFloat = 0
    @State private var taglineShown = false
    @State private var done = false

    private let logoSize: CGFloat = 54

    var body: some View {
        ZStack {
            InkColor.paper.ignoresSafeArea()
            RuledLines(progress: ruled)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                ZStack(alignment: .topLeading) {
                    InkBlot()
                        .fill(InkColor.inkDrop)
                        .frame(width: 30, height: 30)
                        .scaleEffect(blot, anchor: .center)
                        .opacity(blot > 0 ? 1 : 0)
                        .offset(x: -26, y: -6)
                    Image(systemName: "drop.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(InkColor.inkDrop)
                        .offset(x: -21, y: dropFallen ? -4 : -420)
                        .opacity(dropFallen && blot > 0 ? 0 : 1)
                    logo
                }
                Text(L10n.t("splash.tagline"))
                    .font(.inkVoice(16))
                    .foregroundStyle(InkColor.teacher)
                    .opacity(taglineShown ? 1 : 0)
                    .offset(y: taglineShown ? 0 : 6)
            }
            .padding(.leading, InkSpace.marginLineX + 40)
            .frame(maxWidth: .infinity, alignment: .leading)
            .offset(y: -40)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: leave)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Ink & Irony")
        .accessibilityAddTraits(.isHeader)
        .task { await play() }
    }

    private var logo: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(handwritten: "Ink & Irony")
                .font(.inkDisplayFixed(logoSize))
                .foregroundStyle(InkColor.teacher)
                .lineLimit(1)
                .fixedSize()
                .rotationEffect(.degrees(-2))
                .mask(alignment: .leading) { PenReveal(progress: written) }
            Scribble()
                .trim(from: 0, to: underlined)
                .stroke(InkColor.teacher, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: logoSize * 3.6, height: 14)
        }
    }

    private func play() async {
        if reduceMotion {
            ruled = 1; dropFallen = true; blot = 1; written = 1; underlined = 1
            withAnimation(.easeOut(duration: 0.2)) { taglineShown = true }
            try? await Task.sleep(for: .milliseconds(700))
            leave()
            return
        }
        withAnimation(.easeOut(duration: 0.3)) { ruled = 1 }
        try? await Task.sleep(for: .milliseconds(80))
        // Gravity is the one honest use of ease-in.
        withAnimation(.easeIn(duration: 0.26)) { dropFallen = true }
        try? await Task.sleep(for: .milliseconds(260))
        HapticService.shared.playPenStrike()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) { blot = 1 }
        // The pen moves at a steady hand: start and stop soft, constant in between.
        withAnimation(.timingCurve(0.4, 0, 0.6, 1, duration: 0.45)) { written = 1 }
        try? await Task.sleep(for: .milliseconds(380))
        withAnimation(.easeOut(duration: 0.22)) { underlined = 1 }
        try? await Task.sleep(for: .milliseconds(120))
        withAnimation(.easeOut(duration: 0.2)) { taglineShown = true }
        try? await Task.sleep(for: .milliseconds(450))
        leave()
    }

    private func leave() {
        guard !done else { return }
        done = true
        finish()
    }
}

/// Ruled lines and the margin line, drawn in from the left and the top.
private struct RuledLines: View, Animatable {
    var progress: CGFloat
    var lineSpacing: CGFloat = 32

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    var body: some View {
        Canvas { context, size in
            var y = lineSpacing - 1
            var row: CGFloat = 0
            while y < size.height {
                // Each line lags the one above a little, as if ruled top to bottom.
                let local = min(max(progress * 1.4 - row * 0.012, 0), 1)
                context.fill(Path(CGRect(x: 0, y: y, width: size.width * local, height: 1)), with: .color(InkColor.ruledLine))
                y += lineSpacing
                row += 1
            }
            context.fill(Path(CGRect(x: InkSpace.marginLineX, y: 0, width: 2, height: size.height * progress)), with: .color(InkColor.marginLine))
        }
        .accessibilityHidden(true)
    }
}

/// Mask that uncovers text left to right with a soft, wet leading edge.
private struct PenReveal: View {
    var progress: CGFloat
    private let feather: CGFloat = 28

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                Rectangle()
                LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                    .frame(width: feather)
            }
            .frame(width: (proxy.size.width + feather) * progress, height: proxy.size.height + 40)
            .offset(y: -20)
        }
    }
}

/// A fountain-pen blot: a round splash with a few droplets thrown off it.
struct InkBlot: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        var path = Path()
        path.addEllipse(in: CGRect(x: w * 0.18, y: h * 0.2, width: w * 0.62, height: h * 0.58))
        path.addEllipse(in: CGRect(x: w * 0.5, y: h * 0.12, width: w * 0.36, height: h * 0.34))
        path.addEllipse(in: CGRect(x: w * 0.12, y: h * 0.5, width: w * 0.34, height: h * 0.36))
        path.addEllipse(in: CGRect(x: w * 0.86, y: h * 0.62, width: w * 0.12, height: h * 0.12))
        path.addEllipse(in: CGRect(x: w * 0.02, y: h * 0.14, width: w * 0.09, height: h * 0.09))
        path.addEllipse(in: CGRect(x: w * 0.58, y: h * 0.86, width: w * 0.08, height: h * 0.08))
        return path
    }
}
