import Combine
import CoreGraphics
import Foundation

final class SessionRecipeStepNode: Node, ObservableObject {
    let id = UUID()
    var label: SessionRecipeStep
    var position: CGPoint?
    @Published var isCompletable = false
    @Published var isCompleted = false

    init(_ node: RecipeStepNode, actionTimeTracker: ActionTimeTracker, position: CGPoint? = nil) {
        self.label = SessionRecipeStep(step: node.label, actionTimeTracker: actionTimeTracker)
        self.position = position
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
