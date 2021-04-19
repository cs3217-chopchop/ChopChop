import Combine
import Foundation

final class SelectionHandler<T: Node>: ObservableObject {
    @Published private(set) var selectedNodeIds: [UUID] = []

    func isNodeSelected(_ node: T) -> Bool {
        selectedNodeIds.contains(node.id)
    }

    func selectNode(_ node: T) {
        guard !selectedNodeIds.contains(node.id) else {
            return
        }

        selectedNodeIds = [node.id]
    }

    func deselectNode(_ node: T) {
        selectedNodeIds.removeAll(where: { $0 == node.id })
    }

    func toggleNode(_ node: T) {
        selectedNodeIds.contains(node.id) ? deselectNode(node) : selectNode(node)
    }

    func deselectAllNodes() {
        selectedNodeIds = []
    }
}
