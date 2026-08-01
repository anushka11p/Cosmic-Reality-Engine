import SwiftUI

struct StarField: View {
    struct Star {
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let brightness: Double
        let layer: Int
    }

    private let stars: [Star] = {
        var s: [Star] = []
        var seed: UInt64 = 42
        func rnd() -> CGFloat {
            seed = seed &* 6364136223846793005 &+ 1
            return CGFloat((seed >> 33) % 10000) / 10000
        }
        for layer in 0..<3 {
            for _ in 0..<80 {
                s.append(Star(x: rnd(), y: rnd(), size: CGFloat(layer + 1) * 0.6,
                               brightness: Double.random(in: 0.2...0.9), layer: layer))
            }
        }
        return s
    }()

    let center: CGPoint
    let pullStrength: CGFloat   // 0 = normal, >0 = pulled toward center (Big Bang)

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let c = CGPoint(x: center.x * size.width, y: center.y * size.height)
                for star in stars {
                    var pos = CGPoint(x: star.x * size.width, y: star.y * size.height)
                    if pullStrength > 0 {
                        pos.x = pos.x + (c.x - pos.x) * pullStrength
                        pos.y = pos.y + (c.y - pos.y) * pullStrength
                    }
                    let rect = CGRect(x: pos.x, y: pos.y, width: star.size, height: star.size)
                    context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(star.brightness)))
                }
            }
        }
    }
}
