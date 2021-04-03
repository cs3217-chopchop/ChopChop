import SwiftGraph
import SwiftUI

final class EditorGraphViewModel: ObservableObject {
    @Published var portalPosition = CGVector.zero
    @Published var linePhase = CGFloat.zero

    var graph: RecipeStepGraph

    init(graph: RecipeStepGraph) {
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

    func onLongPressPortal(_ value: DragGesture.Value) {
        guard let step = try? RecipeStep(content: "Add step details...") else {
            return
        }

        graph.addNode(RecipeStepNode(step, position: value.location - portalPosition))
        self.objectWillChange.send()
    }

    func onDragNode(_ value: DragGesture.Value, node: RecipeStepNode) -> NodeDragInfo {
        NodeDragInfo(id: node.id, offset: CGVector(dx: value.translation.width, dy: value.translation.height))
    }

    func onLongPressDragNode(_ value: DragGesture.Value, position: CGPoint) -> LineDragInfo {
        LineDragInfo(from: position + portalPosition, to: value.location)
    }

    func onLongPressDragNodeEnd(_ value: DragGesture.Value, node: RecipeStepNode) {
        if let targetNode = hitTest(point: value.location),
           let edge = Edge(source: node, destination: targetNode) {
            try? graph.addEdge(edge)
        }
    }

    private func hitTest(point: CGPoint) -> RecipeStepNode? {
        for node in graph.nodes {
            guard let position = node.position else {
                continue
            }

            let endPoint = position + portalPosition - CGVector(dx: RecipeStepNode.normalSize.width / 2,
                                                                dy: RecipeStepNode.normalSize.height / 2)
            let rect = CGRect(origin: endPoint, size: RecipeStepNode.normalSize)

            if rect.contains(point) {
                return node
            }
        }

        return nil
    }
}

extension EditorGraphViewModel {
    struct NodeDragInfo {
        let id: UUID
        let offset: CGVector
    }

    struct LineDragInfo {
        let from: CGPoint
        let to: CGPoint
    }
}