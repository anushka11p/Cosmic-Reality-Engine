import SwiftUI
import Vision

struct HandSkeletonOverlay: View {
    @ObservedObject var camera = CosmicCameraController.shared

    private let connections: [(VNHumanHandPoseObservation.JointName, VNHumanHandPoseObservation.JointName)] = [
        (.wrist, .thumbCMC), (.thumbCMC, .thumbMP), (.thumbMP, .thumbIP), (.thumbIP, .thumbTip),
        (.wrist, .indexMCP), (.indexMCP, .indexPIP), (.indexPIP, .indexDIP), (.indexDIP, .indexTip),
        (.wrist, .middleMCP), (.middleMCP, .middlePIP), (.middlePIP, .middleDIP), (.middleDIP, .middleTip),
        (.wrist, .ringMCP), (.ringMCP, .ringPIP), (.ringPIP, .ringDIP), (.ringDIP, .ringTip),
        (.wrist, .littleMCP), (.littleMCP, .littlePIP), (.littlePIP, .littleDIP), (.littleDIP, .littleTip),
        (.indexMCP, .middleMCP), (.middleMCP, .ringMCP), (.ringMCP, .littleMCP)
    ]

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                for hand in camera.hands {
                    for (a, b) in connections {
                        if let pa = hand.landmarks[a], let pb = hand.landmarks[b] {
                            let sa = CameraCoordinateMapper.convert(pa, videoDimensions: camera.videoDimensions, viewSize: size)
                            let sb = CameraCoordinateMapper.convert(pb, videoDimensions: camera.videoDimensions, viewSize: size)
                            var path = Path()
                            path.move(to: sa)
                            path.addLine(to: sb)
                            context.stroke(path, with: .color(.cyan.opacity(0.55)), lineWidth: 1.5)
                        }
                    }
                    for (_, point) in hand.landmarks {
                        let p = CameraCoordinateMapper.convert(point, videoDimensions: camera.videoDimensions, viewSize: size)
                        context.fill(Path(ellipseIn: CGRect(x: p.x - 2, y: p.y - 2, width: 4, height: 4)), with: .color(.white.opacity(0.75)))
                    }
                }
            }
        }
    }
}
