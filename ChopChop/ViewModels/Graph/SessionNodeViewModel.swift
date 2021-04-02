import Combine
import SwiftGraph

final class SessionNodeViewModel: ObservableObject {
    private var graph: UnweightedGraph<Node2>
    let node: Node2
    let index: Int?

    init(graph: UnweightedGraph<Node2>, node: Node2) {
        self.graph = graph
        self.node = node
        self.index = graph.topologicalSort()?.firstIndex(of: node)
    }
}
