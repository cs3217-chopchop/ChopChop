import Combine

final class TimerNodeViewModel: ObservableObject {
    var graph: SessionRecipeStepGraph
    let node: SessionRecipeStepNode
    let index: Int?

    var hasTimers: Bool {
        !node.label.timers.isEmpty
    }

    init(graph: SessionRecipeStepGraph, node: SessionRecipeStepNode) {
        self.graph = graph
        self.node = node
        self.index = graph.topologicallySortedNodes.firstIndex(of: node)
    }
}
