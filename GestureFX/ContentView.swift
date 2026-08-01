import SwiftUI

struct ContentView: View {

    @ObservedObject private var effects =
        EffectsEngine.shared

    var body: some View {
        ZStack {
            CosmicMetalView()
                .ignoresSafeArea()

            spaceDarkeningOverlay

            StarfieldBackground()

            CosmicDimensionView()
                .ignoresSafeArea()

            HandSkeletonOverlay()
                .ignoresSafeArea()

            BigBangEffect()
                .ignoresSafeArea()
        }
        .background(Color.black)
        .ignoresSafeArea()
        .frame(
            minWidth: 900,
            minHeight: 650
        )
        .onAppear {
            CosmicCameraController.shared.start()

            SoundEngine.shared.loadSound(
                named: "Dimensional_Drift"
            )
        }
        .onDisappear {
            CosmicCameraController.shared.stop()
        }
    }

    private var spaceDarkeningOverlay: some View {
        ZStack {
            Color.black
                .opacity(
                    effects.objectVisible
                    ? 0.42
                    : 0
                )

            LinearGradient(
                colors: [
                    Color(
                        red: 0.01,
                        green: 0.02,
                        blue: 0.10
                    )
                    .opacity(
                        effects.objectVisible
                        ? 0.34
                        : 0
                    ),

                    Color.black.opacity(
                        effects.objectVisible
                        ? 0.18
                        : 0
                    ),

                    Color(
                        red: 0.02,
                        green: 0.01,
                        blue: 0.09
                    )
                    .opacity(
                        effects.objectVisible
                        ? 0.30
                        : 0
                    )
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    Color.clear,

                    Color.black.opacity(
                        effects.objectVisible
                        ? 0.18
                        : 0
                    ),

                    Color.black.opacity(
                        effects.objectVisible
                        ? 0.60
                        : 0
                    )
                ],
                center: UnitPoint(
                    x: effects.objectCenter.x,
                    y: 1 -
                        effects.objectCenter.y
                ),
                startRadius: 130,
                endRadius: 900
            )
        }
        .animation(
            .easeInOut(duration: 0.9),
            value: effects.objectVisible
        )
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}
