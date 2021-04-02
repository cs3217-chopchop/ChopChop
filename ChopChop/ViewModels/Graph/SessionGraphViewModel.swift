import SwiftGraph
import SwiftUI

final class SessionGraphViewModel: ObservableObject {
    @Published var portalPosition = CGVector.zero

    var graph: UnweightedGraph<Node2>

    init(graph: UnweightedGraph<Node2>) {
        self.graph = graph
    }

    func onDragPortal(_ value: DragGesture.Value) {
        portalPosition += CGVector(dx: value.translation.width, dy: value.translation.height)
    }
}
