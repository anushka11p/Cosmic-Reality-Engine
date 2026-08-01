import SwiftUI

struct BigBangEffect: View {
    @ObservedObject var effects = EffectsEngine.shared
    @State private var progress: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            if effects.bigBangActive {
                let center = CameraCoordinateMapper.convert(
                    effects.objectCenter,
                    videoDimensions: CosmicCameraController.shared.videoDimensions,
                    viewSize: geo.size
                )

                ZStack {
                    // White flash, fades fast
                    Color.white
                        .opacity(max(0, 1.0 - progress * 4))
                        .ignoresSafeArea()

                    // Expanding shockwave ring
                    Circle()
                        .stroke(Color.white.opacity(max(0, 1 - progress)), lineWidth: 3)
                        .frame(width: 40 + progress * 900, height: 40 + progress * 900)
                        .position(center)

                    Circle()
                        .stroke(Color.cyan.opacity(max(0, 0.6 - progress)), lineWidth: 2)
                        .frame(width: 20 + progress * 650, height: 20 + progress * 650)
                        .position(center)

                    // Star field pulled inward then blown outward
                    StarField(center: CGPoint(x: center.x / geo.size.width, y: center.y / geo.size.height),
                              pullStrength: progress < 0.3 ? (0.3 - progress) * 2 : 0)
                }
                .onAppear { startAnimation() }
            }
        }
    }

    private func startAnimation() {
        progress = 0
        withAnimation(.easeOut(duration: 2.4)) {
            progress = 1.0
        }
    }
}
