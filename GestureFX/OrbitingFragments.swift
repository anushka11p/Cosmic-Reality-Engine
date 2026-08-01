import SwiftUI

struct OrbitingFragments: View {

    @ObservedObject private var effects =
        EffectsEngine.shared

    let center: CGPoint

    private let fragmentCount = 14

    var body: some View {
        Canvas(
            opaque: false,
            colorMode: .linear,
            rendersAsynchronously: true
        ) { context, _ in

            for index in 0..<fragmentCount {
                let seed = Double(index)

                let angle =
                    effects.pulse * (
                        0.12 +
                        Double(index % 4) * 0.025
                    ) +
                    seed * 0.78

                let orbitRadius =
                    (
                        135 +
                        CGFloat(index % 5) * 17
                    ) *
                    effects.objectScale

                let verticalScale =
                    0.38 +
                    CGFloat(index % 3) * 0.08

                let x =
                    center.x +
                    cos(angle) * orbitRadius

                let y =
                    center.y +
                    sin(angle) *
                    orbitRadius *
                    verticalScale

                let depth =
                    (sin(angle) + 1) / 2

                let fragmentSize =
                    (
                        3.5 +
                        CGFloat(index % 4) * 1.2
                    ) *
                    effects.objectScale *
                    (
                        0.65 +
                        CGFloat(depth) * 0.45
                    )

                let opacity =
                    0.22 +
                    depth * 0.48

                var shard = Path()

                shard.move(
                    to: CGPoint(
                        x: x,
                        y: y - fragmentSize
                    )
                )

                shard.addLine(
                    to: CGPoint(
                        x: x + fragmentSize * 0.55,
                        y: y
                    )
                )

                shard.addLine(
                    to: CGPoint(
                        x: x,
                        y: y + fragmentSize
                    )
                )

                shard.addLine(
                    to: CGPoint(
                        x: x - fragmentSize * 0.42,
                        y: y
                    )
                )

                shard.closeSubpath()

                let color: Color =
                    index.isMultiple(of: 3)
                    ? .white
                    : index.isMultiple(of: 2)
                    ? .cyan
                    : .blue

                context.fill(
                    shard,
                    with: .color(
                        color.opacity(opacity)
                    )
                )
            }
        }
        .allowsHitTesting(false)
    }
}
