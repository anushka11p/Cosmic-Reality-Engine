import Vision
import CoreGraphics

struct TrackedHand {
    let landmarks: [VNHumanHandPoseObservation.JointName: CGPoint]
    let center: CGPoint
}

func extractTrackedHand(from observation: VNHumanHandPoseObservation) -> TrackedHand? {
    guard let all = try? observation.recognizedPoints(.all) else { return nil }
    var points: [VNHumanHandPoseObservation.JointName: CGPoint] = [:]
    for (name, point) in all where point.confidence > 0.3 {
        points[name] = point.location
    }
    guard let wrist = points[.wrist] else { return nil }
    return TrackedHand(landmarks: points, center: wrist)
}
