import Combine
import CoreGraphics
import SwiftGraph

final class GraphViewModel: ObservableObject {
    var graph: UnweightedGraph<Node>

    init(graph: UnweightedGraph<Node>) {
        self.graph = graph
    }
}
