import CoreGraphics
import Foundation

final class RecipeStepNode: Node {
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
        lhs.label == rhs.label
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
}
