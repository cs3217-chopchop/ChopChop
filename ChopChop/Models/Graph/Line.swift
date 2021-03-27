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
        let center = from + (to - from) / 2
        let leftArrow = (center - (to - from).normalized() * 10).rotate(around: center, by: .pi / 3)
        let rightArrow = (center - (to - from).normalized() * 10).rotate(around: center, by: -.pi / 3)
        let topArrow = center + (to - from).normalized() * 10

        return Path { path in
            path.move(to: from)
            path.addLine(to: to)
            path.addLines([leftArrow, topArrow, rightArrow])
        }
    }
}
