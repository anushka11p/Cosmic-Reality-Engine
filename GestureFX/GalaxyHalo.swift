import SwiftUI

struct GalaxyHalo: View {

    @ObservedObject private var effects =
        EffectsEngine.shared

    let center: CGPoint

    @State private var spinning = false

    var body: some View {
        ZStack {

            // Soft local dimming only
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.clear,
                            Color.black.opacity(0.05),
                            Color.black.opacity(0.12),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 40,
                        endRadius: 190
                    )
                )
                .frame(
                    width: 360 * effects.objectScale,
                    height: 360 * effects.objectScale
                )
                .blur(radius: 18)

            // Faint nebula glow
            Circle()
                .fill(
                    AngularGradient(
                        colors: [
                            Color.cyan.opacity(0.10),
                            Color.blue.opacity(0.08),
                            Color.purple.opacity(0.12),
                            Color.clear,
                            Color.cyan.opacity(0.08)
                        ],
                        center: .center
                    )
                )
                .frame(
                    width: 300 * effects.objectScale,
                    height: 300 * effects.objectScale
                )
                .blur(radius: 34)
                .rotationEffect(
                    .degrees(spinning ? 360 : 0)
                )
                .blendMode(.screen)

            // Very subtle orbit line
            Ellipse()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.cyan.opacity(0.18),
                            Color.white.opacity(0.12),
                            Color.purple.opacity(0.14),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1
                )
                .frame(
                    width: 250 * effects.objectScale,
                    height: 80 * effects.objectScale
                )
                .rotationEffect(
                    .degrees(spinning ? -360 : 0)
                )
                .opacity(0.7)
        }
        .position(center)
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(
                .linear(duration: 28)
                .repeatForever(autoreverses: false)
            ) {
                spinning = true
            }
        }
    }
}
