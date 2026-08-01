import SwiftUI
import MetalKit
import CoreImage
import CoreImage.CIFilterBuiltins

final class CosmicRenderer: NSObject, MTKViewDelegate {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let ciContext: CIContext

    private var currentBuffer: CVPixelBuffer?
    private let bufferLock = NSLock()

    override init() {
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue()!
        ciContext = CIContext(mtlDevice: device, options: [.cacheIntermediates: false])
        super.init()
    }

    func update(pixelBuffer: CVPixelBuffer) {
        bufferLock.lock()
        currentBuffer = pixelBuffer
        bufferLock.unlock()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else { return }

        bufferLock.lock()
        let buffer = currentBuffer
        bufferLock.unlock()
        guard let pixelBuffer = buffer else { return }

        autoreleasepool {
            var image = CIImage(cvPixelBuffer: pixelBuffer)

            image = image.transformed(by: CGAffineTransform(scaleX: -1, y: 1))
                         .transformed(by: CGAffineTransform(translationX: image.extent.width, y: 0))

            let extent = image.extent
            let effects = EffectsEngine.shared

            if effects.objectVisible {
                let vignette = CIFilter.vignette()
                vignette.inputImage = image
                vignette.intensity = 0.9
                vignette.radius = 1.8
                image = vignette.outputImage ?? image
            }

            if effects.bigBangActive {
                let cx = (1 - effects.objectCenter.x) * extent.width
                let cy = effects.objectCenter.y * extent.height

                let pinch = CIFilter.pinchDistortion()
                pinch.inputImage = image
                pinch.center = CGPoint(x: cx, y: cy)
                pinch.radius = Float(420 * max(0.6, effects.objectScale))
                pinch.scale = -0.7
                image = pinch.outputImage ?? image
            }

            guard let colorSpace = CGColorSpaceCreateDeviceRGB() as CGColorSpace? else { return }
            let commandBuffer = commandQueue.makeCommandBuffer()
            ciContext.render(image, to: drawable.texture, commandBuffer: commandBuffer,
                              bounds: CGRect(origin: .zero, size: view.drawableSize), colorSpace: colorSpace)
            commandBuffer?.present(drawable)
            commandBuffer?.commit()
        }
    }
}

struct CosmicMetalView: NSViewRepresentable {
    @ObservedObject var camera = CosmicCameraController.shared

    func makeCoordinator() -> CosmicRenderer { CosmicRenderer() }

    func makeNSView(context: Context) -> MTKView {
        let view = MTKView()
        view.device = context.coordinator.device
        view.delegate = context.coordinator
        view.framebufferOnly = false
        view.isPaused = false
        view.enableSetNeedsDisplay = false
        view.preferredFramesPerSecond = 30
        view.colorPixelFormat = .bgra8Unorm
        camera.pixelBufferHandler = { buffer in
            context.coordinator.update(pixelBuffer: buffer)
        }
        return view
    }

    func updateNSView(_ nsView: MTKView, context: Context) {}
}
