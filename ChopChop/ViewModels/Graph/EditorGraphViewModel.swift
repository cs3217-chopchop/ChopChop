import SwiftGraph
import SwiftUI

final class EditorGraphViewModel: ObservableObject {
    @Published var portalPosition = CGVector.zero
    @Published var linePhase = CGFloat.zero

    var graph: UnweightedGraph<Node2>

    init(graph: UnweightedGraph<Node2>) {
        self.graph = graph
    }

    func onDragPortal(_ value: DragGesture.Value) {
        portalPosition += CGVector(dx: value.translation.width, dy: value.translation.height)
    }

    func onLongPressPortal(_ value: DragGesture.Value) {
        _ = graph.addVertex(Node2(position: value.location - portalPosition))
        self.objectWillChange.send()
    }

    func onDragNode(_ value: DragGesture.Value, node: Node2) -> NodeDragInfo {
        NodeDragInfo(id: node.id, offset: CGVector(dx: value.translation.width, dy: value.translation.height))
    }

    func onLongPressDragNode(_ value: DragGesture.Value, position: CGPoint) -> LineDragInfo {
        LineDragInfo(from: position + portalPosition, to: value.location)
    }

    func onLongPressDragNodeEnd(_ value: DragGesture.Value, node: Node2) {
        if let targetNode = hitTest(point: value.location) {
            graph.addEdge(from: node, to: targetNode, directed: true)
        }
    }

    private func hitTest(point: CGPoint) -> Node2? {
        for node in graph.vertices {
            let endPoint = node.position + portalPosition - CGVector(dx: Node2.normalSize.width / 2,
                                                                     dy: Node2.normalSize.height / 2)
            let rect = CGRect(origin: endPoint, size: Node2.normalSize)

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

extension UnweightedEdge: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(u)
        hasher.combine(v)
        hasher.combine(directed)
    }
}
