import CoreGraphics
import Foundation

final class RecipeStepNode: Node {
    let id = UUID()
    var label: RecipeStep
    var position: CGPoint?
    var timers: [TimeInterval]

    init(_ label: RecipeStep, position: CGPoint? = nil, timers: [TimeInterval] = []) {
        self.label = label
        self.position = position
        self.timers = timers
    }
}

extension RecipeStepNode: Equatable {
    static func == (lhs: RecipeStepNode, rhs: RecipeStepNode) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

extension RecipeStepNode: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension RecipeStepNode {
    static let normalSize = CGSize(width: 162, height: 108)
    static let expandedSize = CGSize(width: 360, height: 240)

    static let horizontalDistance = RecipeStepNode.normalSize.width * 1.25
    static let verticalDistance = RecipeStepNode.normalSize.height * 1.4
}
