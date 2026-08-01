import Foundation
import CoreGraphics
import Combine

final class EffectsEngine: ObservableObject {
    static let shared = EffectsEngine()

    @Published var objectVisible: Bool = false
    @Published var objectCenter: CGPoint = CGPoint(x: 0.5, y: 0.5)
    @Published var objectScale: CGFloat = 1.0
    @Published var rotationXW: Double = 0
    @Published var rotationYZ: Double = 0

    @Published var bigBangActive: Bool = false
    @Published var bigBangTrigger: Bool = false

    private var rotationVelocityXW: Double = 0
    private var rotationVelocityYZ: Double = 0

    private var lastAngle: Double?
    private var lastDistance: CGFloat?
    private var lastUpdateTime: Date = Date()
    private var missingHandsCount = 0

    private var lastBigBangTime: Date = .distantPast
    private let bigBangCooldown: TimeInterval = 4.0

    func update(hands: [TrackedHand]) {
        let now = Date()
        let dt = max(0.001, now.timeIntervalSince(lastUpdateTime))
        lastUpdateTime = now

        guard hands.count == 2, !bigBangActive else {
            missingHandsCount += 1
            if missingHandsCount > 20 {
                objectVisible = false
                rotationVelocityXW *= 0.95
                rotationVelocityYZ *= 0.95
                rotationXW += rotationVelocityXW * dt
                rotationYZ += rotationVelocityYZ * dt
            }
            return
        }
        missingHandsCount = 0

        let a = hands[0].center
        let b = hands[1].center

        let targetCenter = CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
        objectCenter = lerp(objectCenter, targetCenter, 0.28)

        let dx = b.x - a.x
        let dy = b.y - a.y
        let distance = sqrt(dx*dx + dy*dy)

        // Capture PREVIOUS distance BEFORE we overwrite it — this was the bug
        let previousDistance = lastDistance

        let targetScale = max(0.5, min(3.2, distance * 4.2))
        objectScale = lerp1D(objectScale, targetScale, 0.22)

        let angle = atan2(dy, dx)
        if let last = lastAngle {
            var delta = angle - last
            if delta > .pi { delta -= 2 * .pi }
            if delta < -.pi { delta += 2 * .pi }
            let clamped = max(-0.3, min(0.3, delta))
            rotationVelocityYZ = lerp1D(rotationVelocityYZ, clamped * 3.5, 0.35)
        }
        lastAngle = angle

        if let lastDist = previousDistance {
            let distDelta = distance - lastDist
            let clamped = max(-0.05, min(0.05, distDelta))
            rotationVelocityXW = lerp1D(rotationVelocityXW, clamped * 4.5, 0.35)
        }

        rotationXW += rotationVelocityXW
        rotationYZ += rotationVelocityYZ

        // Clap detection using the CORRECT previous distance
        if let lastDist = previousDistance, distance < 0.09 {
            let closingSpeed = (lastDist - distance) / CGFloat(dt)
            if closingSpeed > 0.5, now.timeIntervalSince(lastBigBangTime) > bigBangCooldown {
                triggerBigBang()
            }
        }

        lastDistance = distance
        objectVisible = true
    }

    private func triggerBigBang() {
        lastBigBangTime = Date()
        bigBangActive = true
        bigBangTrigger.toggle()
        objectVisible = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
            self.bigBangActive = false
        }
    }

    private func lerp(_ a: CGPoint, _ b: CGPoint, _ t: CGFloat) -> CGPoint {
        CGPoint(x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t)
    }
    private func lerp1D(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat { a + (b - a) * t }
    private func lerp1D(_ a: Double, _ b: Double, _ t: Double) -> Double { a + (b - a) * t }
}
