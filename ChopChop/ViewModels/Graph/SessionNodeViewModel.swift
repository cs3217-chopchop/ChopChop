import Combine

final class SessionNodeViewModel: ObservableObject {
    var graph: SessionRecipeStepGraph
    let node: SessionRecipeStepNode
    let index: Int?

    init(graph: SessionRecipeStepGraph, node: SessionRecipeStepNode) {
        self.graph = graph
        self.node = node
        self.index = graph.topologicallySortedNodes.firstIndex(of: node)
    }
}
