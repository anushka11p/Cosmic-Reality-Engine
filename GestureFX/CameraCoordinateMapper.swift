import CoreGraphics

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

        // Vision coordinates (origin bottom-left)
        let imageX = point.x * videoDimensions.width
        let imageY = (1.0 - point.y) * videoDimensions.height

        // Aspect Fill
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
