import Combine
import SwiftGraph

final class NodeViewModel: ObservableObject {
    @Published var isEditing = false
    @Published var text = ""

    private var graph: UnweightedGraph<Node>
    let node: Node
    let index: Int?

    init(graph: UnweightedGraph<Node>, node: Node) {
        self.graph = graph
        self.node = node

        self.text = node.text
        self.index = graph.topologicalSort()?.firstIndex(of: node)
    }

    func removeNode() {
        graph.removeVertex(node)
    }
}
