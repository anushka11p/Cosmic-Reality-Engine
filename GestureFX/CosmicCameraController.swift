import Foundation
import AVFoundation
import Vision
import Combine
import CoreGraphics

final class CosmicCameraController: NSObject, ObservableObject {

    static let shared = CosmicCameraController()

    let session = AVCaptureSession()

    private let videoOutput = AVCaptureVideoDataOutput()

    @Published var hands: [TrackedHand] = []

    @Published var videoDimensions =
        CGSize(width: 640, height: 480)

    var pixelBufferHandler: ((CVPixelBuffer) -> Void)?

    private var hasStarted = false

    private let videoQueue = DispatchQueue(
        label: "cosmic.video.queue",
        qos: .userInitiated
    )

    private lazy var handPoseRequest: VNDetectHumanHandPoseRequest = {
        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = 2
        return request
    }()

    func start() {
        guard !hasStarted else {
            return
        }

        hasStarted = true

        session.beginConfiguration()
        session.sessionPreset = .medium

        guard
            let camera = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: camera),
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
            queue: videoQueue
        )

        guard session.canAddOutput(videoOutput) else {
            session.commitConfiguration()
            hasStarted = false
            return
        }

        session.addOutput(videoOutput)

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
        guard hasStarted else {
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            if self.session.isRunning {
                self.session.stopRunning()
            }

            DispatchQueue.main.async {
                self.hands = []
                self.hasStarted = false

                EffectsEngine.shared.update(
                    hands: []
                )
            }
        }
    }
}

extension CosmicCameraController:
    AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        autoreleasepool {
            guard let pixelBuffer =
                    CMSampleBufferGetImageBuffer(sampleBuffer)
            else {
                return
            }

            pixelBufferHandler?(pixelBuffer)

            var dimensions =
                CGSize(width: 640, height: 480)

            if let formatDescription =
                CMSampleBufferGetFormatDescription(sampleBuffer) {

                let rawDimensions =
                    CMVideoFormatDescriptionGetDimensions(
                        formatDescription
                    )

                dimensions = CGSize(
                    width: CGFloat(rawDimensions.width),
                    height: CGFloat(rawDimensions.height)
                )
            }

            let handler = VNImageRequestHandler(
                cvPixelBuffer: pixelBuffer,
                orientation: .up,
                options: [:]
            )

            do {
                try handler.perform([
                    handPoseRequest
                ])
            } catch {
                print(
                    "Hand detection failed:",
                    error.localizedDescription
                )
                return
            }

            guard
                let observations = handPoseRequest.results,
                !observations.isEmpty
            else {
                DispatchQueue.main.async {
                    self.hands = []
                    self.videoDimensions = dimensions

                    EffectsEngine.shared.update(
                        hands: []
                    )
                }

                return
            }

            let trackedHands = observations.compactMap {
                extractTrackedHand(from: $0)
            }

            DispatchQueue.main.async {
                self.hands = trackedHands
                self.videoDimensions = dimensions

                EffectsEngine.shared.update(
                    hands: trackedHands
                )
            }
        }
    }
}
