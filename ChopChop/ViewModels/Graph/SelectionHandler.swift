import Combine
import Foundation

/**
 Represents a component that tracks which node is currently selected.
 */
final class SelectionHandler<T: Node>: ObservableObject {
    /// The collection of currently selected nodes.
    @Published private(set) var selectedNodeIds: [UUID] = []

    /**
     Returns whether the given node is currently selected.
     */
    func isNodeSelected(_ node: T) -> Bool {
        selectedNodeIds.contains(node.id)
    }

    /**
     Selects the given node and unselects all other nodes.
     If the given node is already selected, do nothing.
     */
    func selectNode(_ node: T) {
        guard !selectedNodeIds.contains(node.id) else {
            return
        }

        selectedNodeIds = [node.id]
    }

    /**
     Unselects the given node.
     */
    func deselectNode(_ node: T) {
        selectedNodeIds.removeAll(where: { $0 == node.id })
    }

    /**
     Toggles whether the given node is selected.
     */
    func toggleNode(_ node: T) {
        selectedNodeIds.contains(node.id) ? deselectNode(node) : selectNode(node)
    }

    /**
     Unselects all nodes.
     */
    func deselectAllNodes() {
        selectedNodeIds = []
    }
}
