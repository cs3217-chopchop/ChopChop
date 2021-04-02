import SwiftUI

final class SessionRecipeStepNode: Node, ObservableObject {
    var label: SessionRecipeStep
    @Published var isCompletable = false
    @Published var isCompleted = false

    init(_ node: RecipeStepNode, actionTimeTracker: ActionTimeTracker) {
        self.label = SessionRecipeStep(step: node.label, actionTimeTracker: actionTimeTracker)
    }
}

extension SessionRecipeStepNode: Hashable {
    static func == (lhs: SessionRecipeStepNode, rhs: SessionRecipeStepNode) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
