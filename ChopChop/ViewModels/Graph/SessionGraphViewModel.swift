import SwiftUI

final class SessionGraphViewModel: ObservableObject {
    @Published var portalPosition = CGVector.zero
    @Published var showTimerPanel = false

    var graph: SessionRecipeStepGraph

    init(graph: SessionRecipeStepGraph) {
        self.graph = graph
        graph.positionNodes()
    }

    func onDragPortal(_ value: DragGesture.Value) {
        portalPosition += CGVector(dx: value.translation.width, dy: value.translation.height)
    }
}
