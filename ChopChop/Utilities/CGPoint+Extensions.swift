import CoreGraphics

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = point.x - x
        let dy = point.y - y

        return sqrt(dx * dx + dy * dy)
    }
}
