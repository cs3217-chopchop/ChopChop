import CoreGraphics
import Foundation

/**
 Represents a node in the session recipe step graph.
 
 Representation Invariants:
 - Label is valid.
 - If it is completed, it is completable.
 */
final class SessionRecipeStepNode: Node {
    // MARK: - Specification Fields
    /// The step that the node represents.
    var label: SessionRecipeStep
    /// A flag that represents whether the step is completable.
    var isCompletable = false
    /// A flag that represents whether the step has been completed.
    var isCompleted = false

    let id = UUID()
    var position: CGPoint?

    /**
     Initialises a session node with the given recipe node.
     */
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
