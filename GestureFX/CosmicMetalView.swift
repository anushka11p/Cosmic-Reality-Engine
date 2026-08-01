import SwiftUI
import MetalKit
import CoreImage
import CoreImage.CIFilterBuiltins

final class CosmicRenderer: NSObject, MTKViewDelegate {

    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let ciContext: CIContext

    private let lock = NSLock()
    private var currentBuffer: CVPixelBuffer?

    override init() {
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue()
        else {
            fatalError("Metal is not supported on this Mac.")
        }

        self.device = device
        self.commandQueue = commandQueue

        self.ciContext = CIContext(
            mtlDevice: device,
            options: [
                .cacheIntermediates: false
            ]
        )

        super.init()
    }

    func update(pixelBuffer: CVPixelBuffer) {
        lock.lock()
        currentBuffer = pixelBuffer
        lock.unlock()
    }

    func mtkView(
        _ view: MTKView,
        drawableSizeWillChange size: CGSize
    ) {}

    func draw(in view: MTKView) {
        autoreleasepool {
            guard
                let drawable = view.currentDrawable,
                let commandBuffer = commandQueue.makeCommandBuffer()
            else {
                return
            }

            lock.lock()
            let buffer = currentBuffer
            lock.unlock()

            guard let buffer else {
                return
            }

            let drawableSize = view.drawableSize

            guard
                drawableSize.width > 1,
                drawableSize.height > 1
            else {
                return
            }

            let targetBounds = CGRect(
                origin: .zero,
                size: drawableSize
            )

            // Unmirrored camera image.
            var image = CIImage(
                cvPixelBuffer: buffer
            )

            // Scale camera to fill the whole Metal view.
            image = aspectFill(
                image: image,
                into: targetBounds
            )

            let effects = EffectsEngine.shared

            if effects.objectVisible {
                let vignette = CIFilter.vignette()
                let objectCenter = CGPoint(
                    x:
                        effects.objectCenter.x *
                        drawableSize.width,

                    y:
                        effects.objectCenter.y *
                        drawableSize.height
                )

                let lens = CIFilter.bumpDistortion()

                lens.inputImage =
                    image.clampedToExtent()

                lens.center = objectCenter

                lens.radius = Float(
                    115 *
                    max(
                        effects.objectScale,
                        0.7
                    )
                )

                lens.scale = 0.10

                if let output = lens.outputImage {
                    image = output.cropped(
                        to: targetBounds
                    )
                }

                vignette.inputImage = image
                vignette.intensity = 0.22
                
                vignette.radius = Float(
                    max(
                        drawableSize.width,
                        drawableSize.height
                    ) * 0.88
                )

                image = vignette.outputImage ?? image
            }

            if effects.bigBangActive {
                let center = CGPoint(
                    x: effects.objectCenter.x * drawableSize.width,
                    y: effects.objectCenter.y * drawableSize.height
                )

                let distortion = CIFilter.bumpDistortion()

                distortion.inputImage = image
                distortion.center = center
                distortion.radius = Float(
                    420 * max(
                        effects.objectScale,
                        0.6
                    )
                )
                distortion.scale = 0.85

                image = distortion.outputImage ?? image
            }

            image = image.cropped(
                to: targetBounds
            )

            ciContext.render(
                image,
                to: drawable.texture,
                commandBuffer: commandBuffer,
                bounds: targetBounds,
                colorSpace: CGColorSpaceCreateDeviceRGB()
            )

            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }

    private func aspectFill(
        image: CIImage,
        into targetBounds: CGRect
    ) -> CIImage {
        let sourceExtent = image.extent

        guard
            sourceExtent.width > 0,
            sourceExtent.height > 0
        else {
            return image
        }

        let scaleX =
            targetBounds.width /
            sourceExtent.width

        let scaleY =
            targetBounds.height /
            sourceExtent.height

        let scale = max(
            scaleX,
            scaleY
        )

        let scaledImage = image.transformed(
            by: CGAffineTransform(
                scaleX: scale,
                y: scale
            )
        )

        let scaledExtent = scaledImage.extent

        let translationX =
            targetBounds.midX -
            scaledExtent.midX

        let translationY =
            targetBounds.midY -
            scaledExtent.midY

        return scaledImage
            .transformed(
                by: CGAffineTransform(
                    translationX: translationX,
                    y: translationY
                )
            )
            .cropped(
                to: targetBounds
            )
    }
}

struct CosmicMetalView: NSViewRepresentable {

    @ObservedObject private var camera =
        CosmicCameraController.shared

    func makeCoordinator() -> CosmicRenderer {
        CosmicRenderer()
    }

    func makeNSView(
        context: Context
    ) -> MTKView {
        let view = MTKView(
            frame: .zero,
            device: context.coordinator.device
        )

        view.delegate = context.coordinator
        view.framebufferOnly = false
        view.autoResizeDrawable = true
        view.isPaused = false
        view.enableSetNeedsDisplay = false
        view.preferredFramesPerSecond = 30
        view.colorPixelFormat = .bgra8Unorm

        view.clearColor = MTLClearColor(
            red: 0,
            green: 0,
            blue: 0,
            alpha: 1
        )

        camera.pixelBufferHandler = { pixelBuffer in
            context.coordinator.update(
                pixelBuffer: pixelBuffer
            )
        }

        return view
    }

    func updateNSView(
        _ nsView: MTKView,
        context: Context
    ) {
        let scaleFactor =
            nsView.window?.backingScaleFactor ?? 1.0

        nsView.drawableSize = CGSize(
            width: max(
                nsView.bounds.width * scaleFactor,
                1
            ),
            height: max(
                nsView.bounds.height * scaleFactor,
                1
            )
        )
    }

    static func dismantleNSView(
        _ nsView: MTKView,
        coordinator: CosmicRenderer
    ) {
        CosmicCameraController.shared
            .pixelBufferHandler = nil

        nsView.delegate = nil
    }
}
