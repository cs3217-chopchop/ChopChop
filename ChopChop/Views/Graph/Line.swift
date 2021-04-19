import SwiftUI

/**
 Represents a line shape from a point to another.
 */
struct Line: Shape {

    // MARK: - Specification Fields
    /// The starting point of the line.
    var from: CGPoint
    /// The ending point of the line.
    var to: CGPoint

    var animatableData: AnimatablePair<CGPoint.AnimatableData, CGPoint.AnimatableData> {
        get {
            AnimatablePair(from.animatableData, to.animatableData)
        }

        set {
            from.animatableData = newValue.first
            to.animatableData = newValue.second
        }
    }

    /**
     Returns a path representing the line in the given rect.
     The path traces the line with an arrow head at the center.
     */
    func path(in rect: CGRect) -> Path {
        let lineVector = to - from
        let center = from + lineVector / 2
        let arrowVector = lineVector.normalized() * 6
        let arrowAngle = Angle.degrees(75)

        let leftPoint = (center - arrowVector).rotate(around: center, by: arrowAngle)
        let midPoint = center + arrowVector
        let rightPoint = (center - arrowVector).rotate(around: center, by: -arrowAngle)

        return Path { path in
            path.move(to: from)
            path.addLine(to: to)
            path.addLines([leftPoint, midPoint, rightPoint])
        }
    }
}
