import SwiftUI

struct ContentView: View {

    @ObservedObject private var effects =
        EffectsEngine.shared

    // MARK: - Retro Palette
    // Mild, period-accurate palette: closer to default 90s browser
    // link/text colors (navy, maroon, olive) than a neon sign.
    private let retroNavy   = Color(red: 0.15, green: 0.20, blue: 0.55)
    private let retroMaroon = Color(red: 0.55, green: 0.15, blue: 0.20)
    private let retroOlive  = Color(red: 0.55, green: 0.50, blue: 0.15)
    private let retroSteel  = Color(red: 0.55, green: 0.60, blue: 0.65)
    private let retroGreen  = Color(red: 0.35, green: 0.60, blue: 0.35)
    private let retroRust   = Color(red: 0.65, green: 0.35, blue: 0.15)

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
        .overlay(alignment: .topLeading) {
            retroControlPanel
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

    // MARK: - Retro Panel

    private var retroControlPanel: some View {
        VStack(
            alignment: .leading,
            spacing: 8
        ) {
            neonTitle("COSMIC ENGINE")

            Text("~ Dimensional Reality Interface ~")
                .font(
                    .system(
                        size: 11,
                        weight: .regular,
                        design: .serif
                    )
                )
                .italic()
                .foregroundStyle(retroNavy)
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )

            retroRule()

            Text(
                effects.bigBangActive
                ? "!! WARNING: REALITY COLLAPSE IN PROGRESS !!"
                : effects.objectVisible
                    ? "Dimensional drift is currently active."
                    : "Welcome. Hold both palms in view to begin."
            )
            .font(
                .system(
                    size: 12,
                    weight: effects.bigBangActive
                        ? .bold
                        : .regular,
                    design: .serif
                )
            )
            .foregroundStyle(
                effects.bigBangActive
                ? retroMaroon
                : retroOlive
            )
            .frame(
                maxWidth: .infinity,
                alignment: .center
            )
            .padding(.vertical, 4)
            .multilineTextAlignment(.center)

            retroSectionTitle("DIMENSIONAL COMMANDS")

            retroCommand(
                title: "Initialize Dimensional Core",
                description:
                    "Hold both palms in front of the camera."
            )

            retroCommand(
                title: "Expand Energy Field",
                description:
                    "Move both hands farther apart."
            )

            retroCommand(
                title: "Compress Energy Field",
                description:
                    "Move both hands closer together."
            )

            retroCommand(
                title: "Rotate Hypercube",
                description:
                    "Rotate the position of both hands."
            )

            retroCommand(
                title: "Trigger Reality Collapse",
                description:
                    "Clap both hands together quickly."
            )

            retroSectionTitle("SYSTEM STATUS")

            statusLine(
                name: "DIMENSIONAL CORE",
                value: effects.objectVisible
                    ? "ONLINE"
                    : "OFFLINE"
            )

            statusLine(
                name: "ENERGY FIELD",
                value: effects.bigBangActive
                    ? "CRITICAL"
                    : effects.objectVisible
                        ? "STABLE"
                        : "DORMANT"
            )

            statusLine(
                name: "REALITY STATE",
                value: effects.bigBangActive
                    ? "UNSTABLE"
                    : "NORMAL"
            )

            retroRule()

            Text("Best viewed in full dimensional resolution")
                .font(.system(size: 9, weight: .regular, design: .monospaced))
                .foregroundStyle(retroMaroon.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .center)

            Text("© 1997 COSMIC ENGINE — Experimental Interface")
                .font(.system(size: 9, weight: .regular, design: .monospaced))
                .foregroundStyle(retroNavy.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(12)
        .frame(width: 340)
        .background(retroPanelBackground)
        .overlay(retroPanelBorder)
        .padding(.top, 20)
        .padding(.leading, 20)
        .allowsHitTesting(false)
    }

    // Translucent black — NOT solid opaque gray — so the cosmic
    // scene behind the panel stays visible through it, same way
    // old sites layered content over a starfield <body background>.
    private var retroPanelBackground: some View {
        Color.black.opacity(0.68)
    }

    // A single thin border, evocative of old <table border=1> framing —
    // not a double-color neon outline.
    private var retroPanelBorder: some View {
        Rectangle()
            .stroke(retroSteel.opacity(0.6), lineWidth: 1)
    }

    // Plain bold serif title, single flat color — a normal
    // <h1> header, not a glowing GIF banner.
    private func neonTitle(_ text: String) -> some View {
        Text(text)
            .font(
                .system(
                    size: 24,
                    weight: .bold,
                    design: .serif
                )
            )
            .foregroundStyle(retroRust)
            .frame(
                maxWidth: .infinity,
                alignment: .center
            )
    }

    // Thin flat rule standing in for a plain <hr>.
    private func retroRule() -> some View {
        Rectangle()
            .fill(retroSteel.opacity(0.5))
            .frame(height: 1)
    }

    private func retroSectionTitle(
        _ text: String
    ) -> some View {
        Text(text)
            .font(
                .system(
                    size: 14,
                    weight: .bold,
                    design: .serif
                )
            )
            .tracking(1)
            .foregroundStyle(retroNavy)
            .underline()
            .padding(.top, 4)
    }

    private func retroCommand(
        title: String,
        description: String
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 2
        ) {
            HStack(spacing: 4) {
                Text("-")
                    .font(.system(size: 13, weight: .semibold, design: .serif))
                    .foregroundStyle(retroMaroon)

                Text(title)
                    .font(
                        .system(
                            size: 13,
                            weight: .semibold,
                            design: .serif
                        )
                    )
                    .foregroundStyle(retroMaroon)
            }

            Text(description)
                .font(
                    .system(
                        size: 11,
                        design: .serif
                    )
                )
                .foregroundStyle(Color.white.opacity(0.85))
                .padding(.leading, 14)
        }
    }

    private func statusLine(
        name: String,
        value: String
    ) -> some View {
        HStack {
            Text(name)
                .font(
                    .system(
                        size: 11,
                        design: .monospaced
                    )
                )
                .foregroundStyle(Color.white.opacity(0.8))

            Spacer()

            Text("[ \(value) ]")
                .font(
                    .system(
                        size: 11,
                        weight: .bold,
                        design: .monospaced
                    )
                )
                .foregroundStyle(
                    value == "CRITICAL" || value == "UNSTABLE"
                    ? retroMaroon
                    : (value == "ONLINE" || value == "STABLE" || value == "NORMAL"
                        ? retroGreen
                        : retroOlive)
                )
        }
    }

    // MARK: - Space Darkening (unchanged)

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
                    y: 1 - effects.objectCenter.y
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
