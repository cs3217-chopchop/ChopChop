import SwiftUI

struct Line: Shape {
    var from: CGPoint
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

    func path(in rect: CGRect) -> Path {
        let lineVector = to - from
        let center = from + lineVector / 2
        let arrowVector = lineVector.normalized() * 8
        let arrowAngle = Angle.degrees(60)

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
