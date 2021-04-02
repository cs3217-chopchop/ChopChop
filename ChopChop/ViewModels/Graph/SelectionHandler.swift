import Combine
import Foundation

final class SelectionHandler: ObservableObject {
    @Published private(set) var selectedNodeIds: [UUID] = []

    func isNodeSelected(_ node: RecipeStepNode) -> Bool {
        selectedNodeIds.contains(node.id)
    }

    func selectNode(_ node: RecipeStepNode) {
        selectedNodeIds = [node.id]
    }

    func deselectNode(_ node: RecipeStepNode) {
        selectedNodeIds.removeAll(where: { $0 == node.id })
    }

    func toggleNode(_ node: RecipeStepNode) {
        selectedNodeIds.contains(node.id) ? deselectNode(node) : selectNode(node)
    }

    func deselectAllNodes() {
        selectedNodeIds = []
    }
}
