import SwiftUI

final class SessionNodeViewModel: ObservableObject {
    var graph: SessionRecipeStepGraph
    let node: SessionRecipeStepNode
    let index: Int?

    var proxy: ScrollViewProxy?

    init(graph: SessionRecipeStepGraph, node: SessionRecipeStepNode, proxy: ScrollViewProxy? = nil) {
        self.graph = graph
        self.node = node
        self.index = graph.topologicallySortedNodes.firstIndex(of: node)
        self.proxy = proxy
    }
}
