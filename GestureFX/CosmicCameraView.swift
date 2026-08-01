import SwiftUI
import AVFoundation
import Vision
import Combine

enum CameraCoordinateMapper {

    static func convert(
        _ point: CGPoint,
        videoDimensions: CGSize,
        viewSize: CGSize
    ) -> CGPoint {

        guard
            videoDimensions.width > 0,
            videoDimensions.height > 0,
            viewSize.width > 0,
            viewSize.height > 0
        else {
            return .zero
        }

        let imageX = point.x * videoDimensions.width
        let imageY = (1 - point.y) * videoDimensions.height

        let scale = max(
            viewSize.width / videoDimensions.width,
            viewSize.height / videoDimensions.height
        )

        let scaledWidth = videoDimensions.width * scale
        let scaledHeight = videoDimensions.height * scale

        let offsetX = (scaledWidth - viewSize.width) / 2
        let offsetY = (scaledHeight - viewSize.height) / 2

        return CGPoint(
            x: imageX * scale - offsetX,
            y: imageY * scale - offsetY
        )
    }
}

final class CosmicCameraController: NSObject, ObservableObject {

    static let shared = CosmicCameraController()

    let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()

    @Published var hands: [TrackedHand] = []
    @Published var videoDimensions = CGSize(width: 640, height: 480)

    // Called with the raw pixel buffer every frame, so the Metal renderer
    // can draw the live camera feed with real lensing applied.
    var pixelBufferHandler: ((CVPixelBuffer) -> Void)?

    private var hasStarted = false

    func start() {
        guard !hasStarted else { return }
        hasStarted = true

        session.beginConfiguration()
        session.sessionPreset = .medium

        guard
            let device = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else {
            session.commitConfiguration()
            hasStarted = false
            return
        }
        session.addInput(input)

        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(
            self,
            queue: DispatchQueue(label: "cosmic.video.queue", qos: .userInitiated)
        )

        guard session.canAddOutput(videoOutput) else {
            session.commitConfiguration()
            hasStarted = false
            return
        }
        session.addOutput(videoOutput)

        // Vision reads the raw, unmirrored frame. Mirroring is applied
        // visually by the Metal renderer instead.
        if let connection = videoOutput.connection(with: .video),
           connection.isVideoMirroringSupported {
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = false
        }

        session.commitConfiguration()

        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }

    func stop() {
        guard hasStarted else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
            DispatchQueue.main.async {
                self.hands = []
                self.hasStarted = false
                EffectsEngine.shared.update(hands: [])
            }
        }
    }
}

extension CosmicCameraController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        autoreleasepool {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

            // Feed the Metal renderer the latest frame
            pixelBufferHandler?(pixelBuffer)

            var dimensions = CGSize(width: 640, height: 480)
            if let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) {
                let rawDimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
                dimensions = CGSize(width: CGFloat(rawDimensions.width), height: CGFloat(rawDimensions.height))
            }

            let request = VNDetectHumanHandPoseRequest()
            request.maximumHandCount = 2

            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])

            do {
                try handler.perform([request])
            } catch {
                print("Hand pose detection failed:", error)
                return
            }

            guard let observations = request.results, !observations.isEmpty else {
                DispatchQueue.main.async {
                    self.hands = []
                    self.videoDimensions = dimensions
                    EffectsEngine.shared.update(hands: [])
                }
                return
            }

            let trackedHands = observations.compactMap { extractTrackedHand(from: $0) }

            DispatchQueue.main.async {
                self.hands = trackedHands
                self.videoDimensions = dimensions
                EffectsEngine.shared.update(hands: trackedHands)
            }
        }
    }
}
