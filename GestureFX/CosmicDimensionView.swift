import SwiftUI

struct CosmicDimensionView: View {

    @ObservedObject private var effects =
        EffectsEngine.shared

    @ObservedObject private var camera =
        CosmicCameraController.shared

    var body: some View {
        GeometryReader { geometry in
            if effects.objectVisible {
                let center =
                    CameraCoordinateMapper.convert(
                        effects.objectCenter,
                        videoDimensions:
                            camera.videoDimensions,
                        viewSize:
                            geometry.size
                    )

                ZStack {
                    GalaxyHalo(
                        center: center
                    )
                    .opacity(0.72)

                    OrbitingFragments(
                        center: center
                    )

                    TesseractRenderer(
                        center: center
                    )

                    CrystalCore(
                        center: center
                    )
                    .opacity(0.82)
                }
                .transition(
                    .opacity.combined(
                        with: .scale(
                            scale: 0.82,
                            anchor: .center
                        )
                    )
                )
            }
        }
        .allowsHitTesting(false)
        .animation(
            .easeOut(duration: 0.22),
            value: effects.objectVisible
        )
    }
}
