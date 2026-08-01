import SwiftUI

struct CrystalCore: View {

    @ObservedObject private var effects =
        EffectsEngine.shared

    let center: CGPoint

    var body: some View {
        ZStack {
            outerAtmosphere

            energyRings

            crystalBody

            innerEnergyCore

            specularHighlight
        }
        .position(center)
        .allowsHitTesting(false)
    }

    // MARK: - Outer volumetric glow

    private var outerAtmosphere: some View {
        let pulse =
            1.0 +
            0.06 * sin(effects.pulse)

        return Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.white.opacity(0.38),
                        Color.cyan.opacity(0.18),
                        Color.blue.opacity(0.10),
                        Color.indigo.opacity(0.05),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius:
                        105 * effects.objectScale
                )
            )
            .frame(
                width:
                    210 *
                    effects.objectScale,

                height:
                    210 *
                    effects.objectScale
            )
            .scaleEffect(pulse)
            .blur(radius: 18)
            .blendMode(.screen)
    }

    // MARK: - Energy rings

    private var energyRings: some View {
        ZStack {
            energyRing(
                size: 112,
                opacity: 0.16,
                phaseOffset: 0
            )

            energyRing(
                size: 86,
                opacity: 0.22,
                phaseOffset: 1.4
            )

            energyRing(
                size: 62,
                opacity: 0.30,
                phaseOffset: 2.8
            )
        }
        .blendMode(.screen)
    }

    private func energyRing(
        size: CGFloat,
        opacity: Double,
        phaseOffset: Double
    ) -> some View {
        let pulse =
            1.0 +
            0.07 *
            sin(
                effects.pulse +
                phaseOffset
            )

        return Circle()
            .stroke(
                AngularGradient(
                    colors: [
                        Color.clear,
                        Color.white.opacity(opacity),
                        Color.cyan.opacity(
                            opacity * 1.2
                        ),
                        Color.blue.opacity(opacity),
                        Color.clear
                    ],
                    center: .center
                ),
                lineWidth:
                    max(
                        0.8,
                        1.4 *
                        effects.objectScale
                    )
            )
            .frame(
                width:
                    size *
                    effects.objectScale,

                height:
                    size *
                    effects.objectScale
            )
            .scaleEffect(pulse)
            .rotationEffect(
                .radians(
                    effects.pulse *
                    (phaseOffset.isZero
                        ? 0.18
                        : -0.12)
                )
            )
            .blur(radius: 0.7)
    }

    // MARK: - Crystal shell

    private var crystalBody: some View {
        ZStack {
            FacetedCrystalShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.74),
                            Color.cyan.opacity(0.20),
                            Color.blue.opacity(0.11),
                            Color.black.opacity(0.28)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            FacetedCrystalShape()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.95),
                            Color.cyan.opacity(0.55),
                            Color.blue.opacity(0.28),
                            Color.white.opacity(0.16)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth:
                        max(
                            1,
                            1.3 *
                            effects.objectScale
                        )
                )

            CrystalFacetLines()
                .stroke(
                    Color.white.opacity(0.25),
                    lineWidth:
                        max(
                            0.5,
                            0.75 *
                            effects.objectScale
                        )
                )

            FacetedCrystalShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.24),
                            Color.clear,
                            Color.blue.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(0.68)
                .rotationEffect(
                    .radians(
                        -effects.pulse * 0.08
                    )
                )
        }
        .frame(
            width:
                92 *
                effects.objectScale,

            height:
                116 *
                effects.objectScale
        )
        .rotation3DEffect(
            .radians(effects.rotationXW),
            axis: (
                x: 1,
                y: 0,
                z: 0
            )
        )
        .rotation3DEffect(
            .radians(effects.rotationYZ),
            axis: (
                x: 0,
                y: 1,
                z: 0
            )
        )
        .rotationEffect(
            .radians(
                effects.rotationZW * 0.35
            )
        )
        .shadow(
            color:
                Color.white.opacity(0.28),
            radius: 5
        )
        .shadow(
            color:
                Color.cyan.opacity(0.32),
            radius: 16
        )
    }

    // MARK: - Inner energy

    private var innerEnergyCore: some View {
        let pulse =
            1.0 +
            0.11 *
            sin(
                effects.pulse * 1.35
            )

        return ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white,
                            Color.cyan.opacity(0.82),
                            Color.blue.opacity(0.32),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius:
                            26 *
                            effects.objectScale
                    )
                )
                .frame(
                    width:
                        52 *
                        effects.objectScale,

                    height:
                        52 *
                        effects.objectScale
                )
                .scaleEffect(pulse)
                .blur(radius: 4)

            Circle()
                .fill(Color.white)
                .frame(
                    width:
                        12 *
                        effects.objectScale,

                    height:
                        12 *
                        effects.objectScale
                )
                .scaleEffect(
                    1.0 +
                    0.08 *
                    sin(
                        effects.pulse * 1.8
                    )
                )
                .shadow(
                    color: .white,
                    radius: 8
                )
        }
        .blendMode(.screen)
    }

    // MARK: - Specular highlight

    private var specularHighlight: some View {
        Ellipse()
            .fill(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.white.opacity(0.55),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(
                width:
                    72 *
                    effects.objectScale,

                height:
                    10 *
                    effects.objectScale
            )
            .rotationEffect(.degrees(-28))
            .offset(
                x:
                    -8 *
                    effects.objectScale,

                y:
                    -18 *
                    effects.objectScale
            )
            .blur(radius: 2)
            .blendMode(.screen)
    }
}

// MARK: - Crystal shape

private struct FacetedCrystalShape: Shape {

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(
            to: CGPoint(
                x: rect.midX,
                y: rect.minY
            )
        )

        path.addLine(
            to: CGPoint(
                x: rect.width * 0.88,
                y: rect.height * 0.24
            )
        )

        path.addLine(
            to: CGPoint(
                x: rect.maxX,
                y: rect.height * 0.62
            )
        )

        path.addLine(
            to: CGPoint(
                x: rect.midX,
                y: rect.maxY
            )
        )

        path.addLine(
            to: CGPoint(
                x: rect.minX,
                y: rect.height * 0.62
            )
        )

        path.addLine(
            to: CGPoint(
                x: rect.width * 0.12,
                y: rect.height * 0.24
            )
        )

        path.closeSubpath()

        return path
    }
}

// MARK: - Facet lines

private struct CrystalFacetLines: Shape {

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let top = CGPoint(
            x: rect.midX,
            y: rect.minY
        )

        let center = CGPoint(
            x: rect.midX,
            y: rect.midY
        )

        let bottom = CGPoint(
            x: rect.midX,
            y: rect.maxY
        )

        let upperLeft = CGPoint(
            x: rect.width * 0.12,
            y: rect.height * 0.24
        )

        let upperRight = CGPoint(
            x: rect.width * 0.88,
            y: rect.height * 0.24
        )

        let lowerLeft = CGPoint(
            x: rect.minX,
            y: rect.height * 0.62
        )

        let lowerRight = CGPoint(
            x: rect.maxX,
            y: rect.height * 0.62
        )

        let outerPoints = [
            top,
            upperLeft,
            upperRight,
            lowerLeft,
            lowerRight,
            bottom
        ]

        for point in outerPoints {
            path.move(to: point)
            path.addLine(to: center)
        }

        path.move(to: upperLeft)
        path.addLine(to: lowerRight)

        path.move(to: upperRight)
        path.addLine(to: lowerLeft)

        return path
    }
}
