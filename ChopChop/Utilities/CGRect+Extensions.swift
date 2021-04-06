import SwiftUI

extension CGRect {
    func rotate(around point: CGPoint, by angle: CGFloat) -> CGRect {
        applying(.rotate(around: point, by: angle))
    }

    func rotate(around point: CGPoint, by angle: Angle) -> CGRect {
        rotate(around: point, by: CGFloat(angle.radians))
    }

    func rotate(by angle: CGFloat) -> CGRect {
        rotate(around: CGPoint(x: midX, y: midY), by: angle)
    }

    func rotate(by angle: Angle) -> CGRect {
        rotate(by: CGFloat(angle.radians))
    }
}
