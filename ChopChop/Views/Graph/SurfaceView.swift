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

    var offset: CGVector {
        CGVector(dx: portalPosition.x + dragOffset.width, dy: portalPosition.y + dragOffset.height)
    }

    var body: some View {
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

            if let nodes = viewModel.graph.topologicalSort() {
                ForEach(nodes) { node in
                    NodeView(selection: selection, node: node, index: 1)
                        .position(node.position + offset
                                    + (selectedNode == node
                                        ? CGVector(dx: dragOffset2.width, dy: dragOffset2.height)
                                        : .zero))
                        .onTapGesture {
                            selection.toggleNode(node)
                        }
                        .gesture(
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

// struct SurfaceView_Previews: PreviewProvider {
//    static var previews: some View {
//        SurfaceView()
//    }
// }
