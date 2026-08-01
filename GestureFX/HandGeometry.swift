import Vision
import CoreGraphics

func angleAt(
    _ pip: CGPoint,
    _ mcp: CGPoint,
    _ tip: CGPoint
) -> CGFloat {
    let firstVector = CGPoint(
        x: mcp.x - pip.x,
        y: mcp.y - pip.y
    )

    let secondVector = CGPoint(
        x: tip.x - pip.x,
        y: tip.y - pip.y
    )

    let dot =
        firstVector.x * secondVector.x +
        firstVector.y * secondVector.y

    let firstMagnitude = hypot(
        firstVector.x,
        firstVector.y
    )

    let secondMagnitude = hypot(
        secondVector.x,
        secondVector.y
    )

    guard
        firstMagnitude > 0,
        secondMagnitude > 0
    else {
        return 0
    }

    let cosine = max(
        -1,
        min(
            1,
            dot /
            (firstMagnitude * secondMagnitude)
        )
    )

    return acos(cosine) * 180 / .pi
}

struct FingerStates {
    let thumb: Bool
    let index: Bool
    let middle: Bool
    let ring: Bool
    let pinky: Bool
}

func fingerStates(
    from observation: VNHumanHandPoseObservation
) throws -> FingerStates {
    let straightThreshold: CGFloat = 155
    let ringThreshold: CGFloat = 130
    let pinkyThreshold: CGFloat = 140

    func point(
        _ joint: VNHumanHandPoseObservation.JointName
    ) -> CGPoint {
        (try? observation.recognizedPoint(joint))?
            .location ?? .zero
    }

    let index = angleAt(
        point(.indexPIP),
        point(.indexMCP),
        point(.indexTip)
    ) >= straightThreshold

    let middle = angleAt(
        point(.middlePIP),
        point(.middleMCP),
        point(.middleTip)
    ) >= straightThreshold

    let ring = angleAt(
        point(.ringPIP),
        point(.ringMCP),
        point(.ringTip)
    ) >= ringThreshold

    let pinky = angleAt(
        point(.littlePIP),
        point(.littleMCP),
        point(.littleTip)
    ) >= pinkyThreshold

    let thumbTip = point(.thumbTip)
    let thumbCMC = point(.thumbCMC)
    let indexMCP = point(.indexMCP)

    let tipDistance = hypot(
        thumbTip.x - indexMCP.x,
        thumbTip.y - indexMCP.y
    )

    let baseDistance = hypot(
        thumbCMC.x - indexMCP.x,
        thumbCMC.y - indexMCP.y
    )

    let thumb =
        baseDistance > 0 &&
        (tipDistance / baseDistance) > 1.2

    return FingerStates(
        thumb: thumb,
        index: index,
        middle: middle,
        ring: ring,
        pinky: pinky
    )
}

func classifyGesture(
    _ states: FingerStates
) -> String {
    let extendedCount = [
        states.thumb,
        states.index,
        states.middle,
        states.ring,
        states.pinky
    ]
    .filter { $0 }
    .count

    if extendedCount == 0 {
        return "FIST"
    }

    if extendedCount == 5 {
        return "OPEN"
    }

    if
        states.index,
        states.middle,
        states.ring,
        !states.pinky,
        !states.thumb
    {
        return "INDEX_MIDDLE_RING"
    }

    if
        states.index,
        states.middle,
        !states.ring,
        !states.pinky,
        !states.thumb
    {
        return "INDEX_MIDDLE"
    }

    if extendedCount == 1 {
        if states.thumb {
            return "THUMB"
        }

        if states.index {
            return "INDEX"
        }

        if states.middle {
            return "MIDDLE"
        }

        if states.ring {
            return "RING"
        }

        if states.pinky {
            return "PINKY"
        }
    }

    return "AMBIGUOUS"
}

struct TrackedHand {
    let landmarks: [
        VNHumanHandPoseObservation.JointName: CGPoint
    ]

    let center: CGPoint
    let wrist: CGPoint
    let gesture: String
}

func extractTrackedHand(
    from observation: VNHumanHandPoseObservation
) -> TrackedHand? {
    guard
        let recognizedPoints =
            try? observation.recognizedPoints(.all)
    else {
        return nil
    }

    var landmarks: [
        VNHumanHandPoseObservation.JointName: CGPoint
    ] = [:]

    for (jointName, recognizedPoint) in recognizedPoints
    where recognizedPoint.confidence > 0.3 {
        landmarks[jointName] =
            recognizedPoint.location
    }

    guard let wrist = landmarks[.wrist] else {
        return nil
    }

    let center = calculatePalmCenter(
        landmarks: landmarks,
        fallback: wrist
    )

    let gesture: String

    if let states = try? fingerStates(
        from: observation
    ) {
        gesture = classifyGesture(states)
    } else {
        gesture = "NONE"
    }

    return TrackedHand(
        landmarks: landmarks,
        center: center,
        wrist: wrist,
        gesture: gesture
    )
}

private func calculatePalmCenter(
    landmarks: [
        VNHumanHandPoseObservation.JointName: CGPoint
    ],
    fallback: CGPoint
) -> CGPoint {
    let preferredJoints: [
        VNHumanHandPoseObservation.JointName
    ] = [
        .wrist,
        .thumbCMC,
        .indexMCP,
        .middleMCP,
        .ringMCP,
        .littleMCP
    ]

    let availablePoints = preferredJoints.compactMap {
        landmarks[$0]
    }

    guard !availablePoints.isEmpty else {
        return fallback
    }

    let total = availablePoints.reduce(
        CGPoint.zero
    ) { partialResult, point in
        CGPoint(
            x: partialResult.x + point.x,
            y: partialResult.y + point.y
        )
    }

    let count = CGFloat(
        availablePoints.count
    )

    let averagedCenter = CGPoint(
        x: total.x / count,
        y: total.y / count
    )

    // Slight bias toward the finger bases so the object sits
    // inside the palm opening rather than too close to the wrist.
    if let middleMCP = landmarks[.middleMCP] {
        return CGPoint(
            x:
                averagedCenter.x * 0.65 +
                middleMCP.x * 0.35,
            y:
                averagedCenter.y * 0.65 +
                middleMCP.y * 0.35
        )
    }

    return averagedCenter
}
