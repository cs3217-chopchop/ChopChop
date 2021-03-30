import SwiftUI

class SessionRecipeStepNode: Node, ObservableObject {
    var label: SessionRecipeStep
    @Published var isCompletable: Bool = false
    @Published var isCompleted: Bool = false

    init(_ node: RecipeStepNode) {
        self.label = SessionRecipeStep(step: node.label, actionTimeTracker: ActionTimeTracker())
    }
}

extension SessionRecipeStepNode: Hashable {
    static func == (lhs: SessionRecipeStepNode, rhs: SessionRecipeStepNode) -> Bool {
        lhs.label == rhs.label
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(label)
    }
}
