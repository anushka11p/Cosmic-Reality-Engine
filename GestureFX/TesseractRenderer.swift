import SwiftUI

struct TesseractRenderer: View {

    @ObservedObject private var effects =
        EffectsEngine.shared

    let center: CGPoint

    var body: some View {
        ZStack {
            renderLayer(
                scale: 1.0,
                rotationMultiplier: 1.0,
                color: Color.white.opacity(0.75),
                lineWidth: 1.6,
                opacity: 0.58
            )

            renderLayer(
                scale: 0.78,
                rotationMultiplier: 1.35,
                color: .cyan,
                lineWidth: 1.6,
                opacity: 0.58
            )

            renderLayer(
                scale: 0.55,
                rotationMultiplier: 1.8,
                color: .blue,
                lineWidth: 1.2,
                opacity: 0.42
            )
        }
        .shadow(
            color: Color.cyan.opacity(0.14),
            radius: 4
        )
        .allowsHitTesting(false)
    }

    private func renderLayer(
        scale: CGFloat,
        rotationMultiplier: Double,
        color: Color,
        lineWidth: CGFloat,
        opacity: Double
    ) -> some View {
        Canvas(
            opaque: false,
            colorMode: .linear,
            rendersAsynchronously: true
        ) { context, _ in

            let projected = DimensionMath.project(
                rotationXY:
                    effects.rotationXY *
                    rotationMultiplier,

                rotationXZ:
                    effects.rotationXZ *
                    rotationMultiplier,

                rotationXW:
                    effects.rotationXW *
                    rotationMultiplier,

                rotationYZ:
                    effects.rotationYZ *
                    rotationMultiplier,

                rotationYW:
                    effects.rotationYW *
                    rotationMultiplier,

                rotationZW:
                    effects.rotationZW *
                    rotationMultiplier,

                scale:
                    effects.objectScale *
                    scale,

                center: center
            )

            for edge in DimensionMath.edges {
                let first = projected[edge.0]
                let second = projected[edge.1]

                let depth =
                    (first.depth + second.depth) / 2

                let depthOpacity = max(
                    0.12,
                    min(
                        1.0,
                        0.32 + depth * 0.52
                    )
                )

                var path = Path()
                path.move(to: first.point)
                path.addLine(to: second.point)

                context.stroke(
                    path,
                    with: .color(
                        color.opacity(
                            opacity * depthOpacity
                        )
                    ),
                    lineWidth: lineWidth
                )
            }
        }
    }
}
