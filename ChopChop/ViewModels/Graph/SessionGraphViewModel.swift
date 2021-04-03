import SwiftUI

final class SessionGraphViewModel: ObservableObject {
    @Published var portalPosition = CGVector.zero

    var graph: SessionRecipeStepGraph

    init(graph: SessionRecipeStepGraph) {
        let maxCount = graph.getNodeLayers().reduce(into: 0) { $0 = max($0, $1.count) }

        for (layerIndex, layer) in graph.getNodeLayers().enumerated() {
            let width = RecipeStepNode.normalSize.width * 1.3
            let height = RecipeStepNode.normalSize.height * 1.4

            for (index, node) in layer.enumerated() {
                node.position = CGPoint(x: CGFloat(index + 1) * width + CGFloat(maxCount - layer.count) * width / 2,
                                        y: CGFloat(layerIndex + 1) * height)
            }
        }

        self.graph = graph
    }

    func onDragPortal(_ value: DragGesture.Value) {
        portalPosition += CGVector(dx: value.translation.width, dy: value.translation.height)
    }
}
