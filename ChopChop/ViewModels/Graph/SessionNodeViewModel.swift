import Combine
import SwiftGraph

final class SessionNodeViewModel: ObservableObject {
    private var graph: UnweightedGraph<Node>
    let node: Node
    let index: Int?

    init(graph: UnweightedGraph<Node>, node: Node) {
        self.graph = graph
        self.node = node
        self.index = graph.topologicalSort()?.firstIndex(of: node)
    }
}
