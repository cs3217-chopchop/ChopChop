import Combine
import CoreGraphics
import Foundation

final class SessionRecipeStepNode: DrawableNode, ObservableObject {
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

extension SessionRecipeStepNode: Hashable {
    static func == (lhs: SessionRecipeStepNode, rhs: SessionRecipeStepNode) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
