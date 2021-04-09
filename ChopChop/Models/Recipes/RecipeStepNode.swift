import CoreGraphics
import Foundation

final class RecipeStepNode: DrawableNode {
    let id = UUID()
    var label: RecipeStep
    var position: CGPoint?

    init(_ label: RecipeStep, position: CGPoint? = nil) {
        self.label = label
        self.position = position
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
    static let normalSize = CGSize(width: 120, height: 84)
    static let expandedSize = CGSize(width: 360, height: 240)

    static let horizontalDistance = RecipeStepNode.normalSize.width * 1.3
    static let verticalDistance = RecipeStepNode.normalSize.height * 1.4
}
