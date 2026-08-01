import Foundation
import CoreGraphics
import Combine

final class EffectsEngine: ObservableObject {

    static let shared = EffectsEngine()

    @Published var objectVisible = false
    @Published var objectCenter = CGPoint(x: 0.5, y: 0.5)
    @Published var objectScale: CGFloat = 1.0

    @Published var rotationXY: Double = 0
    @Published var rotationXZ: Double = 0
    @Published var rotationXW: Double = 0
    @Published var rotationYZ: Double = 0
    @Published var rotationYW: Double = 0
    @Published var rotationZW: Double = 0

    @Published var pulse: Double = 0

    @Published var bigBangActive = false
    @Published var bigBangTrigger = false

    private var centerVelocity = CGPoint.zero
    private var scaleVelocity: CGFloat = 0

    private var rotationVelocityXW: Double = 0
    private var rotationVelocityYZ: Double = 0

    private var lastAngle: Double?
    private var lastDistance: CGFloat?
    private var lastUpdateTime = Date()

    private var missingHandsCount = 0

    private var lastBigBangTime = Date.distantPast
    private let bigBangCooldown: TimeInterval = 4.0

    private init() {}

    func update(hands: [TrackedHand]) {
        let now = Date()

        let deltaTime = min(
            max(
                now.timeIntervalSince(lastUpdateTime),
                0.001
            ),
            0.05
        )

        lastUpdateTime = now
        pulse += deltaTime * 2.4

        guard hands.count == 2, !bigBangActive else {
            handleMissingHands(
                deltaTime: deltaTime
            )
            return
        }

        missingHandsCount = 0

        let firstHand = hands[0].center
        let secondHand = hands[1].center

        let targetCenter = CGPoint(
            x: (firstHand.x + secondHand.x) / 2,
            y: (firstHand.y + secondHand.y) / 2
        )

        updateCenterSpring(
            target: targetCenter,
            deltaTime: deltaTime
        )

        let deltaX = secondHand.x - firstHand.x
        let deltaY = secondHand.y - firstHand.y

        let distance = sqrt(
            deltaX * deltaX +
            deltaY * deltaY
        )

        let previousDistance = lastDistance

        let targetScale = max(
            0.8,
            min(
                3.0,
                distance * 4.0
            )
        )

        updateScaleSpring(
            target: targetScale,
            deltaTime: deltaTime
        )

        updateAngleRotation(
            deltaX: deltaX,
            deltaY: deltaY
        )

        updateDistanceRotation(
            distance: distance,
            previousDistance: previousDistance
        )

        applyRotation(
            deltaTime: deltaTime,
            activeTracking: true
        )

        detectBigBang(
            distance: distance,
            previousDistance: previousDistance,
            deltaTime: deltaTime,
            currentTime: now
        )

        lastDistance = distance
        objectVisible = true
    }

    private func updateCenterSpring(
        target: CGPoint,
        deltaTime: TimeInterval
    ) {
        let stiffness: CGFloat = 34
        let damping: CGFloat = 9

        let displacement = CGPoint(
            x: target.x - objectCenter.x,
            y: target.y - objectCenter.y
        )

        let acceleration = CGPoint(
            x:
                displacement.x * stiffness -
                centerVelocity.x * damping,

            y:
                displacement.y * stiffness -
                centerVelocity.y * damping
        )

        centerVelocity.x +=
            acceleration.x * CGFloat(deltaTime)

        centerVelocity.y +=
            acceleration.y * CGFloat(deltaTime)

        centerVelocity.x = max(
            -1.4,
            min(1.4, centerVelocity.x)
        )

        centerVelocity.y = max(
            -1.4,
            min(1.4, centerVelocity.y)
        )

        objectCenter.x +=
            centerVelocity.x * CGFloat(deltaTime)

        objectCenter.y +=
            centerVelocity.y * CGFloat(deltaTime)

        objectCenter.x = max(
            0,
            min(1, objectCenter.x)
        )

        objectCenter.y = max(
            0,
            min(1, objectCenter.y)
        )
    }

    private func updateScaleSpring(
        target: CGFloat,
        deltaTime: TimeInterval
    ) {
        let stiffness: CGFloat = 28
        let damping: CGFloat = 8

        let displacement =
            target - objectScale

        let acceleration =
            displacement * stiffness -
            scaleVelocity * damping

        scaleVelocity +=
            acceleration * CGFloat(deltaTime)

        scaleVelocity = max(
            -4,
            min(4, scaleVelocity)
        )

        objectScale +=
            scaleVelocity * CGFloat(deltaTime)

        objectScale = max(
            0.65,
            min(3.2, objectScale)
        )
    }

    private func updateAngleRotation(
        deltaX: CGFloat,
        deltaY: CGFloat
    ) {
        let angle = atan2(
            deltaY,
            deltaX
        )

        if let previousAngle = lastAngle {
            var delta = angle - previousAngle

            if delta > .pi {
                delta -= 2 * .pi
            }

            if delta < -.pi {
                delta += 2 * .pi
            }

            let clampedDelta = max(
                -0.24,
                min(
                    0.24,
                    delta
                )
            )

            rotationVelocityYZ = lerp(
                rotationVelocityYZ,
                clampedDelta * 2.6,
                0.22
            )
        }

        lastAngle = angle
    }

    private func updateDistanceRotation(
        distance: CGFloat,
        previousDistance: CGFloat?
    ) {
        guard let previousDistance else {
            return
        }

        let distanceDelta =
            distance - previousDistance

        let clampedDelta = max(
            -0.04,
            min(
                0.04,
                distanceDelta
            )
        )

        rotationVelocityXW = lerp(
            rotationVelocityXW,
            Double(clampedDelta) * 3.4,
            0.24
        )
    }

    private func applyRotation(
        deltaTime: TimeInterval,
        activeTracking: Bool
    ) {
        rotationXW += rotationVelocityXW
        rotationYZ += rotationVelocityYZ

        if activeTracking {
            rotationXY += deltaTime * 0.12
            rotationXZ += deltaTime * 0.09
            rotationYW += deltaTime * 0.07
            rotationZW += deltaTime * 0.11
        } else {
            rotationXY += deltaTime * 0.07
            rotationXZ += deltaTime * 0.05
            rotationYW += deltaTime * 0.04
            rotationZW += deltaTime * 0.06
        }

        rotationVelocityXW *= 0.92
        rotationVelocityYZ *= 0.92
    }

    private func detectBigBang(
        distance: CGFloat,
        previousDistance: CGFloat?,
        deltaTime: TimeInterval,
        currentTime: Date
    ) {
        guard
            let previousDistance,
            distance < 0.09
        else {
            return
        }

        let closingSpeed =
            (previousDistance - distance) /
            CGFloat(deltaTime)

        guard
            closingSpeed > 0.5,
            currentTime.timeIntervalSince(
                lastBigBangTime
            ) > bigBangCooldown
        else {
            return
        }

        triggerBigBang()
    }

    private func handleMissingHands(
        deltaTime: TimeInterval
    ) {
        missingHandsCount += 1

        centerVelocity.x *= 0.86
        centerVelocity.y *= 0.86
        scaleVelocity *= 0.84

        applyRotation(
            deltaTime: deltaTime,
            activeTracking: false
        )

        if missingHandsCount > 12 {
            objectVisible = false
            lastAngle = nil
            lastDistance = nil
            centerVelocity = .zero
            scaleVelocity = 0
        }
    }

    private func triggerBigBang() {
        lastBigBangTime = Date()
        bigBangActive = true
        bigBangTrigger.toggle()
        objectVisible = false

        rotationVelocityXW *= 1.35
        rotationVelocityYZ *= 1.35

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 2.6
        ) { [weak self] in
            self?.bigBangActive = false
        }
    }

    private func lerp(
        _ start: Double,
        _ end: Double,
        _ amount: Double
    ) -> Double {
        start +
            (end - start) * amount
    }
}
