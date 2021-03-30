import SwiftGraph
import SwiftUI

final class SessionGraphViewModel: ObservableObject {
    @Published var portalPosition = CGVector.zero

    var graph: UnweightedGraph<Node>

    init(graph: UnweightedGraph<Node>) {
        self.graph = graph
    }

    func onDragPortal(_ value: DragGesture.Value) {
        portalPosition += CGVector(dx: value.translation.width, dy: value.translation.height)
    }
}
