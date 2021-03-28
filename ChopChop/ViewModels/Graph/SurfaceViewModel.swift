import Combine
import CoreGraphics
import SwiftGraph

final class SurfaceViewModel: ObservableObject {
    let graph: UnweightedGraph<Node>

    init(graph: UnweightedGraph<Node>) {
        self.graph = graph
    }
}
