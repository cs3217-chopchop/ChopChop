import CoreGraphics
import Foundation

final class SessionRecipeStepNode: Node {
    let id = UUID()
    var label: SessionRecipeStep
    var position: CGPoint?

    var isCompletable = true
    var isCompleted = false

    init(node: RecipeStepNode) {
        self.label = SessionRecipeStep(step: node.label)
    }
}

extension SessionRecipeStepNode: Equatable {
    static func == (lhs: SessionRecipeStepNode, rhs: SessionRecipeStepNode) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

extension SessionRecipeStepNode: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
