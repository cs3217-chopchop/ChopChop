import Combine
import Foundation

final class SelectionHandler: ObservableObject {
    @Published private(set) var selectedNodeIds: [UUID] = []

    func isNodeSelected(_ node: Node) -> Bool {
        selectedNodeIds.contains(node.id)
    }

    func selectNode(_ node: Node) {
        selectedNodeIds = [node.id]
    }

    func deselectNode(_ node: Node) {
        selectedNodeIds.removeAll(where: { $0 == node.id })
    }

    func toggleNode(_ node: Node) {
        selectedNodeIds.contains(node.id) ? deselectNode(node) : selectNode(node)
    }

    func deselectAllNodes() {
        selectedNodeIds = []
    }
}
