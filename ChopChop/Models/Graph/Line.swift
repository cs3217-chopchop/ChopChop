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
        let vector = to - from
        let center = from + vector / 2
        let leftPoint = (center - vector.normalized() * 8).rotate(around: center, by: .degrees(60))
        let midPoint = center + vector.normalized() * 8
        let rightPoint = (center - vector.normalized() * 8).rotate(around: center, by: .degrees(-60))

        return Path { path in
            path.move(to: from)
            path.addLine(to: to)
            path.addLines([leftPoint, midPoint, rightPoint])
        }
    }
}
