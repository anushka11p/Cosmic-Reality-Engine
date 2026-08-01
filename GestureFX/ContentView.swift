import SwiftUI

struct ContentView: View {
    @StateObject var camera = CosmicCameraController.shared
    @ObservedObject var effects = EffectsEngine.shared

    var body: some View {
        ZStack {
            CosmicMetalView()
                .ignoresSafeArea()

            StarField(center: effects.objectCenter, pullStrength: 0)
                .opacity(0.5)
                .ignoresSafeArea()

            HandSkeletonOverlay()
                .ignoresSafeArea()

            CosmicDimensionView()
                .ignoresSafeArea()

            BigBangEffect()
                .ignoresSafeArea()

            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Cosmic Reality Engine")
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        Text(effects.objectVisible ? "Object: Active" : "Show both palms to summon")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    .padding(10)
                    .background(.black.opacity(0.4))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    Spacer()
                }
                Spacer()
                HStack {
                    Text("Two palms: summon  •  Rotate: spin  •  Distance: scale  •  Clap fast: Big Bang")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.gray)
                        .padding(8)
                        .background(.black.opacity(0.4))
                        .cornerRadius(6)
                    Spacer()
                }
            }
            .padding()
        }
        .onAppear { camera.start() }
        .frame(minWidth: 900, minHeight: 650)
    }
}
