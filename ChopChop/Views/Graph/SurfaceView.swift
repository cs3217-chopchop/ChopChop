import SwiftUI

struct SurfaceView: View {
    @ObservedObject var viewModel: SurfaceViewModel
    @ObservedObject var selection = SelectionHandler()

    @State var portalPosition = CGPoint.zero
    @State var dragOffset = CGSize.zero
    @State var isDragging = false
    @State var isDraggingGraph = false

    @State var zoomScale: CGFloat = 1.0
    @State var initialZoomScale: CGFloat?
    @State var initialPortalPosition: CGPoint?

    @State var dragOffset2: CGSize = .zero
    @State var selectedNode: Node?
    @GestureState var dragInfo: DragInfo?

    struct DragInfo {
        var from: CGPoint
        var to: CGPoint
    }

    var offset: CGVector {
        CGVector(dx: portalPosition.x + dragOffset.width, dy: portalPosition.y + dragOffset.height)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(viewModel.graph.edgeList(), id: \.description) { edge in
                    Line(from: viewModel.graph.vertexAtIndex(edge.u).position + offset
                            + (selectedNode == viewModel.graph.vertexAtIndex(edge.u)
                                ? CGVector(dx: dragOffset2.width, dy: dragOffset2.height) : .zero),
                         to: viewModel.graph.vertexAtIndex(edge.v).position + offset
                            + (selectedNode == viewModel.graph.vertexAtIndex(edge.v)
                                ? CGVector(dx: dragOffset2.width, dy: dragOffset2.height) : .zero))
                        .stroke(Color.blue, lineWidth: 3)
                }

                if let info = dragInfo {
                    Line(from: info.from, to: info.to)
                        .stroke(Color.red, lineWidth: 3)
                }

                if let nodes = viewModel.graph.topologicalSort() {
                    ForEach(nodes) { node in
                        NodeView(selection: selection, node: node, index: (nodes.firstIndex(of: node) ?? 0) + 1, removeNode: { node in
                            viewModel.graph.removeVertex(node)
                        })
                            .position(node.position + offset
                                        + (selectedNode == node
                                            ? CGVector(dx: dragOffset2.width, dy: dragOffset2.height)
                                            : .zero))
                            .onTapGesture {
                                selection.toggleNode(node)
                            }
                            .gesture(
                                LongPressGesture()
                                    .sequenced(before:
                                        DragGesture()
                                                .updating($dragInfo) { value, state, _ in
                                                    state = DragInfo(from: node.position + CGVector(dx: portalPosition.x,
                                                                                                    dy: portalPosition.y),
                                                                     to: value.location)
                                                }
                                                .onEnded { value in
                                                    if let targetNode = hitTest(point: value.location, parent: geometry.size) {
                                                        viewModel.graph.addEdge(from: node, to: targetNode, directed: true)
                                                    }
                                                }
                                    )
                                    .exclusively(before:
                                        DragGesture()
                                            .onChanged { value in
                                                dragOffset2 = value.translation
                                                selectedNode = node
                                            }
                                            .onEnded { value in
                                                dragOffset2 = .zero
                                                selectedNode = nil
                                                node.position += CGVector(dx: value.translation.width,
                                                                          dy: value.translation.height)
                                            }
                                )
                            )
                    }
                }
            }
            .contentShape(Rectangle())
            .background(Color.orange)
            .onTapGesture {
                selection.unselectAllNodes()
            }
            .gesture(
                LongPressGesture().sequenced(before: DragGesture(minimumDistance: 0).onEnded { value in
                    viewModel.graph.addVertex(Node(position: value.location - CGVector(dx: portalPosition.x,
                                                                                       dy: portalPosition.y),
                                                   text: "Lorem ipsum"))
                    selection.objectWillChange.send()
                }).exclusively(before:
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
                        }
                        .onEnded { value in
                            dragOffset = .zero

                            portalPosition = CGPoint(x: portalPosition.x + value.translation.width,
                                                     y: portalPosition.y + value.translation.height)
                        }
                )
            )
        }
    }
}

extension SurfaceView {
    func hitTest(point: CGPoint, parent: CGSize) -> Node? {
        for node in viewModel.graph.vertices {
            let endPoint = CGPoint(x: node.position.x + portalPosition.x - 60,
                                   y: node.position.y + portalPosition.y - 40)
            let rect = CGRect(origin: endPoint,
                              size: CGSize(width: 120, height: 80))

            if rect.contains(point) {
                return node
            }
        }

        return nil
    }
}

// struct SurfaceView_Previews: PreviewProvider {
//    static var previews: some View {
//        SurfaceView()
//    }
// }
