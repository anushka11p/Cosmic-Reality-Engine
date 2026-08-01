import SwiftUI

struct StarfieldBackground: View {

    @ObservedObject private var effects =
        EffectsEngine.shared

    private let starCount = 180

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas(
                opaque: false,
                colorMode: .linear,
                rendersAsynchronously: true
            ) { context, size in

                guard effects.objectVisible else {
                    return
                }

                let time =
                    timeline.date
                        .timeIntervalSinceReferenceDate

                for index in 0..<starCount {
                    drawStar(
                        index: index,
                        time: time,
                        context: &context,
                        size: size
                    )
                }
            }
        }
        .opacity(
            effects.objectVisible
            ? 1
            : 0
        )
        .animation(
            .easeInOut(duration: 1.1),
            value: effects.objectVisible
        )
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    private func drawStar(
        index: Int,
        time: TimeInterval,
        context: inout GraphicsContext,
        size: CGSize
    ) {
        let xSeed = random(index * 17 + 3)
        let ySeed = random(index * 29 + 11)
        let sizeSeed = random(index * 41 + 7)
        let speedSeed = random(index * 53 + 19)
        let opacitySeed = random(index * 67 + 23)

        let baseX =
            CGFloat(xSeed) *
            size.width

        let baseY =
            CGFloat(ySeed) *
            size.height

        let driftSpeed =
            1.5 +
            CGFloat(speedSeed) * 4

        let drift =
            CGFloat(
                sin(
                    time *
                    (0.08 + speedSeed * 0.07) +
                    Double(index)
                )
            ) *
            driftSpeed

        let x =
            baseX +
            drift

        let y =
            baseY +
            drift * 0.35

        let twinkle =
            0.45 +
            0.55 *
            sin(
                time *
                (0.7 + speedSeed * 1.2) +
                Double(index) * 0.8
            )

        let starSize =
            CGFloat(
                0.7 +
                sizeSeed * 2.2
            )

        let opacity =
            max(
                0.08,
                min(
                    0.75,
                    0.16 +
                    opacitySeed * 0.42 +
                    twinkle * 0.17
                )
            )

        let rect = CGRect(
            x: x - starSize / 2,
            y: y - starSize / 2,
            width: starSize,
            height: starSize
        )

        let color: Color

        if index.isMultiple(of: 11) {
            color = Color.cyan
        } else if index.isMultiple(of: 7) {
            color = Color.blue
        } else {
            color = Color.white
        }

        context.fill(
            Path(ellipseIn: rect),
            with: .color(
                color.opacity(opacity)
            )
        )

        if index.isMultiple(of: 18) {
            var flare = Path()

            flare.move(
                to: CGPoint(
                    x: x - starSize * 3,
                    y: y
                )
            )

            flare.addLine(
                to: CGPoint(
                    x: x + starSize * 3,
                    y: y
                )
            )

            context.stroke(
                flare,
                with: .color(
                    Color.white.opacity(
                        opacity * 0.22
                    )
                ),
                lineWidth: 0.6
            )
        }
    }

    private func random(
        _ seed: Int
    ) -> Double {
        let value =
            sin(Double(seed) * 12.9898) *
            43758.5453

        return value - floor(value)
    }
}
