import Combine
import SwiftGraph

final class EditorNodeViewModel: ObservableObject {
    @Published var isEditing = false
    @Published var text = ""

    private var graph: UnweightedGraph<Node2>
    let node: Node2
    let index: Int?

    init(graph: UnweightedGraph<Node2>, node: Node2) {
        self.graph = graph
        self.node = node

        self.text = node.text
        self.index = graph.topologicalSort()?.firstIndex(of: node)
    }

    func removeNode() {
        graph.removeVertex(node)
    }
}
