import Combine
import Foundation

final class SelectionHandler: ObservableObject {
    @Published private(set) var selectedNodeIds: [UUID] = []

    func selectNode(_ node: Node) {
        selectedNodeIds = [node.id]
    }

    func isNodeSelected(_ node: Node) -> Bool {
        selectedNodeIds.contains(node.id)
    }

    func toggleNode(_ node: Node) {
        if selectedNodeIds.contains(node.id) {
            selectedNodeIds = []
        } else {
            selectNode(node)
        }
    }

    func unselectAllNodes() {
        selectedNodeIds = []
    }
}
