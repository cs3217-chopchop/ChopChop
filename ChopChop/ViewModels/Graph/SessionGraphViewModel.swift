import SwiftUI

/**
 Represents a view model of a view of the graph display of the instructions of a recipe being made.
 */
final class SessionGraphViewModel: ObservableObject {
    /// The graph displayed in the view.
    let graph: SessionRecipeStepGraph
    let proxy: ScrollViewProxy?

    @Published var portalPosition = CGVector.zero

    init(graph: SessionRecipeStepGraph, proxy: ScrollViewProxy? = nil) {
        let maxCount = graph.nodeLayers.reduce(into: 0) { $0 = max($0, $1.count) }

        for (layerIndex, layer) in graph.nodeLayers.enumerated() {
            for (index, node) in layer.enumerated() {
                node.position = CGPoint(x: CGFloat(index + 1) * RecipeStepNode.horizontalDistance
                                            + CGFloat(maxCount - layer.count) * RecipeStepNode.horizontalDistance / 2,
                                        y: CGFloat(layerIndex + 1) * RecipeStepNode.verticalDistance)
            }
        }

        self.graph = graph
        self.proxy = proxy
    }

    func onDragPortal(_ value: DragGesture.Value) {
        portalPosition += CGVector(dx: value.translation.width, dy: value.translation.height)
    }
}
