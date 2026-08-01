import SwiftUI

struct CosmicDimensionView: View {
    @ObservedObject var effects = EffectsEngine.shared
    @ObservedObject var camera = CosmicCameraController.shared

    private static func tesseractVertices() -> [[Double]] {
        var v: [[Double]] = []
        for x in [-1.0, 1.0] {
            for y in [-1.0, 1.0] {
                for z in [-1.0, 1.0] {
                    for w in [-1.0, 1.0] {
                        v.append([x, y, z, w])
                    }
                }
            }
        }
        return v
    }
    private let vertices = tesseractVertices()

    private var edges: [(Int, Int)] {
        var e: [(Int, Int)] = []
        for i in 0..<vertices.count {
            for j in (i+1)..<vertices.count {
                var diff = 0
                for k in 0..<4 where vertices[i][k] != vertices[j][k] { diff += 1 }
                if diff == 1 { e.append((i, j)) }
            }
        }
        return e
    }

    private struct Projected { let x: Double; let y: Double; let depth: Double }

    var body: some View {
        GeometryReader { geo in
            if effects.objectVisible {
                let center = CameraCoordinateMapper.convert(
                    effects.objectCenter, videoDimensions: camera.videoDimensions, viewSize: geo.size
                )

                ZStack {
                    RadialGradient(
                        colors: [Color.blue.opacity(0.4), Color.purple.opacity(0.15), .clear],
                        center: .center, startRadius: 10, endRadius: 260 * effects.objectScale
                    )
                    .frame(width: 520 * effects.objectScale, height: 520 * effects.objectScale)
                    .position(center)
                    .blur(radius: 22)
                    .blendMode(.plusLighter)

                    tesseractLayer(center: center, scale: 1.0, speedMultiplier: 1.0, color: .cyan, lineWidth: 1.3)
                        .blendMode(.plusLighter)
                    tesseractLayer(center: center, scale: 0.7, speedMultiplier: 1.5, color: .blue, lineWidth: 1.5)
                        .blendMode(.plusLighter)
                    tesseractLayer(center: center, scale: 0.4, speedMultiplier: 2.2, color: .purple, lineWidth: 1.7)
                        .blendMode(.plusLighter)

                    crystallineCore(center: center)
                        .blendMode(.plusLighter)
                }
            }
        }
    }

    private func tesseractLayer(center: CGPoint, scale: CGFloat, speedMultiplier: Double, color: Color, lineWidth: CGFloat) -> some View {
        Canvas { context, size in
            let projected = project(vertices, rotXW: effects.rotationXW * speedMultiplier, rotYZ: effects.rotationYZ * speedMultiplier)
            let radius = 260 * effects.objectScale * scale

            for (i, j) in edges {
                let p1 = projected[i], p2 = projected[j]
                let s1 = CGPoint(x: center.x + p1.x * radius, y: center.y + p1.y * radius)
                let s2 = CGPoint(x: center.x + p2.x * radius, y: center.y + p2.y * radius)
                let avgDepth = (p1.depth + p2.depth) / 2
                let opacity = max(0.15, min(1.0, 0.55 + avgDepth * 0.55))

                var path = Path()
                path.move(to: s1); path.addLine(to: s2)
                context.stroke(path, with: .color(color.opacity(opacity)), lineWidth: lineWidth)
            }
        }
    }

    private func crystallineCore(center: CGPoint) -> some View {
        Canvas { context, size in
            let projected = project(vertices, rotXW: effects.rotationXW * 2.6, rotYZ: effects.rotationYZ * 2.6)
            let radius = 90 * effects.objectScale

            // Draw faceted triangles between nearby vertices for a crystal look
            for i in 0..<min(8, projected.count) {
                let p = projected[i]
                let s = CGPoint(x: center.x + p.x * radius, y: center.y + p.y * radius)
                var tri = Path()
                tri.move(to: center)
                tri.addLine(to: s)
                tri.addLine(to: CGPoint(x: center.x + p.y * radius, y: center.y - p.x * radius))
                tri.closeSubpath()
                let depth = max(0.1, min(0.6, 0.3 + p.depth * 0.3))
                context.fill(tri, with: .color(Color.white.opacity(depth * 0.3)))
            }

            let coreGlow = Path(ellipseIn: CGRect(x: center.x - 30 * effects.objectScale, y: center.y - 30 * effects.objectScale,
                                                    width: 60 * effects.objectScale, height: 60 * effects.objectScale))
            context.fill(coreGlow, with: .color(.white.opacity(0.85)))
        }
        .blur(radius: 3)
    }

    private func project(_ verts: [[Double]], rotXW: Double, rotYZ: Double) -> [Projected] {
        verts.map { v in
            var x = v[0], y = v[1], z = v[2], w = v[3]
            let cosXW = cos(rotXW), sinXW = sin(rotXW)
            let x1 = x * cosXW - w * sinXW; let w1 = x * sinXW + w * cosXW
            x = x1; w = w1
            let cosYZ = cos(rotYZ), sinYZ = sin(rotYZ)
            let y1 = y * cosYZ - z * sinYZ; let z1 = y * sinYZ + z * cosYZ
            y = y1; z = z1
            let wFactor = 1.0 / (2.5 - w)
            let x3 = x * wFactor, y3 = y * wFactor, z3 = z * wFactor
            let zFactor = 1.0 / (3.0 - z3)
            return Projected(x: x3 * zFactor, y: y3 * zFactor, depth: z3)
        }
    }
}
