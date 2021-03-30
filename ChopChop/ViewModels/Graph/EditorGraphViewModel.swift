import SwiftGraph
import SwiftUI

final class EditorGraphViewModel: ObservableObject {
    @Published var portalPosition = CGVector.zero
    @Published var linePhase = CGFloat.zero

    var graph: UnweightedGraph<Node>

    init(graph: UnweightedGraph<Node>) {
        self.graph = graph
    }

    func onDragPortal(_ value: DragGesture.Value) {
        portalPosition += CGVector(dx: value.translation.width, dy: value.translation.height)
    }

    func onLongPressPortal(_ value: DragGesture.Value) {
        _ = graph.addVertex(Node(position: value.location - portalPosition))
        self.objectWillChange.send()
    }

    func onDragNode(_ value: DragGesture.Value, node: Node) -> NodeDragInfo {
        NodeDragInfo(id: node.id, offset: CGVector(dx: value.translation.width, dy: value.translation.height))
    }

    func onLongPressDragNode(_ value: DragGesture.Value, position: CGPoint) -> LineDragInfo {
        LineDragInfo(from: position + portalPosition, to: value.location)
    }

    func onLongPressDragNodeEnd(_ value: DragGesture.Value, node: Node) {
        if let targetNode = hitTest(point: value.location) {
            graph.addEdge(from: node, to: targetNode, directed: true)
        }
    }

    private func hitTest(point: CGPoint) -> Node? {
        for node in graph.vertices {
            let endPoint = node.position + portalPosition - CGVector(dx: Node.normalSize.width / 2,
                                                                     dy: Node.normalSize.height / 2)
            let rect = CGRect(origin: endPoint, size: Node.normalSize)

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
