import SwiftUI

/**
 Represents a view model of a view of a step in the instructions of a recipe being made.
 */
final class SessionNodeViewModel: ObservableObject {
    /// The node containing the step displayed in the view.
    let node: SessionRecipeStepNode
    /// The index of the step.
    let index: Int?
    /// The graph that the node belongs to.
    private let graph: SessionRecipeStepGraph

    var proxy: ScrollViewProxy?

    init(graph: SessionRecipeStepGraph, node: SessionRecipeStepNode, proxy: ScrollViewProxy? = nil) {
        self.graph = graph
        self.node = node
        self.index = graph.topologicallySortedNodes.firstIndex(of: node)
        self.proxy = proxy
    }

    func toggleNode() {
        graph.toggleNode(node)
    }
}
