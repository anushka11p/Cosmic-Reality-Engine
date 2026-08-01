import Vision
import CoreGraphics

func angleAt(_ pip: CGPoint, _ mcp: CGPoint, _ tip: CGPoint) -> CGFloat {
    let v1 = CGPoint(x: mcp.x - pip.x, y: mcp.y - pip.y)
    let v2 = CGPoint(x: tip.x - pip.x, y: tip.y - pip.y)
    let dot = v1.x * v2.x + v1.y * v2.y
    let mag1 = hypot(v1.x, v1.y), mag2 = hypot(v2.x, v2.y)
    guard mag1 > 0, mag2 > 0 else { return 0 }
    let cosAngle = max(-1, min(1, dot / (mag1 * mag2)))
    return acos(cosAngle) * 180 / .pi
}

struct FingerStates {
    let thumb, index, middle, ring, pinky: Bool
}

func fingerStates(from obs: VNHumanHandPoseObservation) throws -> FingerStates {
    let T: CGFloat = 155
    let ringT: CGFloat = 130
    let pinkyT: CGFloat = 140

    func pt(_ joint: VNHumanHandPoseObservation.JointName) -> CGPoint {
        (try? obs.recognizedPoint(joint))?.location ?? .zero
    }

    let index  = angleAt(pt(.indexPIP),  pt(.indexMCP),  pt(.indexTip))  >= T
    let middle = angleAt(pt(.middlePIP), pt(.middleMCP), pt(.middleTip)) >= T
    let ring   = angleAt(pt(.ringPIP),   pt(.ringMCP),   pt(.ringTip))   >= ringT
    let pinky  = angleAt(pt(.littlePIP), pt(.littleMCP), pt(.littleTip)) >= pinkyT

    let thumbTip = pt(.thumbTip), thumbMcp = pt(.thumbCMC), indexMcp = pt(.indexMCP)
    let tipDist = hypot(thumbTip.x - indexMcp.x, thumbTip.y - indexMcp.y)
    let mcpDist = hypot(thumbMcp.x - indexMcp.x, thumbMcp.y - indexMcp.y)
    let thumb = mcpDist > 0 && (tipDist / mcpDist) > 1.2

    return FingerStates(thumb: thumb, index: index, middle: middle, ring: ring, pinky: pinky)
}

func classifyGesture(_ f: FingerStates) -> String {
    let count = [f.thumb, f.index, f.middle, f.ring, f.pinky].filter { $0 }.count

    if count == 0 { return "FIST" }
    if count == 5 { return "OPEN" }

    if f.index && f.middle && f.ring && !f.pinky && !f.thumb { return "INDEX_MIDDLE_RING" }
    if f.index && f.middle && !f.ring && !f.pinky && !f.thumb { return "INDEX_MIDDLE" }

    if count == 1 {
        if f.thumb  { return "THUMB" }
        if f.index  { return "INDEX" }
        if f.middle { return "MIDDLE" }
        if f.ring   { return "RING" }
        if f.pinky  { return "PINKY" }
    }
    return "AMBIGUOUS"
}

struct TrackedHand {
    let landmarks: [VNHumanHandPoseObservation.JointName: CGPoint]
    let center: CGPoint
    let gesture: String
}

func extractTrackedHand(from observation: VNHumanHandPoseObservation) -> TrackedHand? {
    guard let all = try? observation.recognizedPoints(.all) else { return nil }
    var points: [VNHumanHandPoseObservation.JointName: CGPoint] = [:]
    for (name, point) in all where point.confidence > 0.3 {
        points[name] = point.location
    }
    guard let wrist = points[.wrist] else { return nil }

    var gesture = "NONE"
    if let states = try? fingerStates(from: observation) {
        gesture = classifyGesture(states)
    }

    return TrackedHand(landmarks: points, center: wrist, gesture: gesture)
}
