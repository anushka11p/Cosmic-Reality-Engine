import Foundation
import CoreGraphics

struct Vertex4D {
    var x: Double
    var y: Double
    var z: Double
    var w: Double
}

struct ProjectedVertex {
    var point: CGPoint
    var depth: Double
}

enum DimensionMath {

    static let vertices: [Vertex4D] = {
        var result: [Vertex4D] = []

        for x in [-1.0, 1.0] {
            for y in [-1.0, 1.0] {
                for z in [-1.0, 1.0] {
                    for w in [-1.0, 1.0] {
                        result.append(
                            Vertex4D(
                                x: x,
                                y: y,
                                z: z,
                                w: w
                            )
                        )
                    }
                }
            }
        }

        return result
    }()

    static let edges: [(Int, Int)] = {
        var result: [(Int, Int)] = []

        for firstIndex in 0..<vertices.count {
            for secondIndex in (firstIndex + 1)..<vertices.count {
                let first = vertices[firstIndex]
                let second = vertices[secondIndex]

                var differences = 0

                if first.x != second.x { differences += 1 }
                if first.y != second.y { differences += 1 }
                if first.z != second.z { differences += 1 }
                if first.w != second.w { differences += 1 }

                if differences == 1 {
                    result.append(
                        (firstIndex, secondIndex)
                    )
                }
            }
        }

        return result
    }()

    static func project(
        rotationXY: Double,
        rotationXZ: Double,
        rotationXW: Double,
        rotationYZ: Double,
        rotationYW: Double,
        rotationZW: Double,
        scale: CGFloat,
        center: CGPoint
    ) -> [ProjectedVertex] {

        vertices.map { sourceVertex in
            var vertex = sourceVertex

            vertex = rotateXY(
                vertex,
                angle: rotationXY
            )

            vertex = rotateXZ(
                vertex,
                angle: rotationXZ
            )

            vertex = rotateXW(
                vertex,
                angle: rotationXW
            )

            vertex = rotateYZ(
                vertex,
                angle: rotationYZ
            )

            vertex = rotateYW(
                vertex,
                angle: rotationYW
            )

            vertex = rotateZW(
                vertex,
                angle: rotationZW
            )

            let fourDimensionalDistance = 3.1
            let fourDimensionalDenominator = max(
                0.35,
                fourDimensionalDistance - vertex.w
            )

            let fourDimensionalScale =
                1.0 / fourDimensionalDenominator

            let x3 = vertex.x * fourDimensionalScale
            let y3 = vertex.y * fourDimensionalScale
            let z3 = vertex.z * fourDimensionalScale

            let cameraDistance = 3.4
            let threeDimensionalDenominator = max(
                0.35,
                cameraDistance - z3
            )

            let threeDimensionalScale =
                1.0 / threeDimensionalDenominator

            let finalX =
                x3 * threeDimensionalScale

            let finalY =
                y3 * threeDimensionalScale

            let radius =
                320 * scale

            return ProjectedVertex(
                point: CGPoint(
                    x: center.x +
                        finalX * radius,
                    y: center.y +
                        finalY * radius
                ),
                depth: z3
            )
        }
    }

    private static func rotateXY(
        _ vertex: Vertex4D,
        angle: Double
    ) -> Vertex4D {
        let cosine = cos(angle)
        let sine = sin(angle)

        return Vertex4D(
            x: vertex.x * cosine -
                vertex.y * sine,
            y: vertex.x * sine +
                vertex.y * cosine,
            z: vertex.z,
            w: vertex.w
        )
    }

    private static func rotateXZ(
        _ vertex: Vertex4D,
        angle: Double
    ) -> Vertex4D {
        let cosine = cos(angle)
        let sine = sin(angle)

        return Vertex4D(
            x: vertex.x * cosine -
                vertex.z * sine,
            y: vertex.y,
            z: vertex.x * sine +
                vertex.z * cosine,
            w: vertex.w
        )
    }

    private static func rotateXW(
        _ vertex: Vertex4D,
        angle: Double
    ) -> Vertex4D {
        let cosine = cos(angle)
        let sine = sin(angle)

        return Vertex4D(
            x: vertex.x * cosine -
                vertex.w * sine,
            y: vertex.y,
            z: vertex.z,
            w: vertex.x * sine +
                vertex.w * cosine
        )
    }

    private static func rotateYZ(
        _ vertex: Vertex4D,
        angle: Double
    ) -> Vertex4D {
        let cosine = cos(angle)
        let sine = sin(angle)

        return Vertex4D(
            x: vertex.x,
            y: vertex.y * cosine -
                vertex.z * sine,
            z: vertex.y * sine +
                vertex.z * cosine,
            w: vertex.w
        )
    }

    private static func rotateYW(
        _ vertex: Vertex4D,
        angle: Double
    ) -> Vertex4D {
        let cosine = cos(angle)
        let sine = sin(angle)

        return Vertex4D(
            x: vertex.x,
            y: vertex.y * cosine -
                vertex.w * sine,
            z: vertex.z,
            w: vertex.y * sine +
                vertex.w * cosine
        )
    }

    private static func rotateZW(
        _ vertex: Vertex4D,
        angle: Double
    ) -> Vertex4D {
        let cosine = cos(angle)
        let sine = sin(angle)

        return Vertex4D(
            x: vertex.x,
            y: vertex.y,
            z: vertex.z * cosine -
                vertex.w * sine,
            w: vertex.z * sine +
                vertex.w * cosine
        )
    }
}
