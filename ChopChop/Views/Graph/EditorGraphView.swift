import SwiftGraph
import SwiftUI

struct EditorGraphView: View {
    @ObservedObject var viewModel: EditorGraphViewModel
    @ObservedObject var selection = SelectionHandler()

    @GestureState var portalDragOffset = CGVector.zero
    @GestureState var nodeDragOffset: EditorGraphViewModel.NodeDragInfo?
    @GestureState var lineDragInfo: EditorGraphViewModel.LineDragInfo?
    @GestureState var placeholderNodePosition: CGPoint?

    var body: some View {
        ZStack {
            linesView

            if let info = lineDragInfo {
                placeholderLineView(info: info)
            }

            if let nodes = viewModel.graph.topologicalSort() {
                nodesView(nodes: nodes)
            }

            if let position = placeholderNodePosition {
                placeholderNodeView(position: position)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                selection.deselectAllNodes()
            }
        }
        .gesture(
            LongPressGesture()
                .sequenced(before: DragGesture(minimumDistance: 0)
                    .updating($placeholderNodePosition) { value, state, _ in
                        state = value.location
                    }
                    .onEnded(viewModel.onLongPressPortal))
                .exclusively(before: DragGesture()
                    .updating($portalDragOffset) { value, state, _ in
                        state = CGVector(dx: value.translation.width, dy: value.translation.height)
                    }
                    .onEnded(viewModel.onDragPortal)
                )
        )
    }

    var linesView: some View {
        ForEach(viewModel.graph.edgeList(), id: \.self) { edge in
            if let offset = nodeDragOffset {
                Line(from: viewModel.graph.vertexAtIndex(edge.u).position
                        + viewModel.portalPosition + portalDragOffset
                        + (viewModel.graph.vertexAtIndex(edge.u).id == offset.id ? offset.offset : .zero),
                     to: viewModel.graph.vertexAtIndex(edge.v).position
                        + viewModel.portalPosition + portalDragOffset
                        + (viewModel.graph.vertexAtIndex(edge.v).id == offset.id ? offset.offset : .zero))
                    .stroke(Color.primary, lineWidth: 1.8)
            } else {
                Line(from: viewModel.graph.vertexAtIndex(edge.u).position
                        + viewModel.portalPosition + portalDragOffset,
                     to: viewModel.graph.vertexAtIndex(edge.v).position
                        + viewModel.portalPosition + portalDragOffset)
                    .stroke(Color.primary, lineWidth: 1.8)
                    .onLongPressGesture {
                        viewModel.graph.removeEdge(edge)
                        viewModel.objectWillChange.send()
                    }
            }
        }
    }

    func placeholderLineView(info: EditorGraphViewModel.LineDragInfo) -> some View {
        Line(from: info.from, to: info.to)
            .stroke(Color.secondary, style: StrokeStyle(lineWidth: 1.8,
                                                        dash: [10],
                                                        dashPhase: viewModel.linePhase))
            .onAppear {
                withAnimation(Animation.linear.repeatForever(autoreverses: false)) {
                    viewModel.linePhase -= 20
                }
            }
    }

    func nodesView(nodes: [Node]) -> some View {
        ForEach(nodes) { node in
            SessionNodeView(viewModel: SessionNodeViewModel(graph: viewModel.graph, node: node), selection: selection)
                .position(node.position + viewModel.portalPosition + portalDragOffset
                            + (nodeDragOffset?.id == node.id ? nodeDragOffset?.offset ?? .zero : .zero))
                .onTapGesture {
                    withAnimation {
                        selection.toggleNode(node)
                    }
                }
                .gesture(
                    LongPressGesture()
                        .sequenced(before: DragGesture()
                            .updating($lineDragInfo) { value, state, _ in
                                state = viewModel.onLongPressDragNode(value, position: node.position)
                            }
                            .onEnded { value in
                                viewModel.onLongPressDragNodeEnd(value, node: node)
                            }
                        )
                        .exclusively(before: DragGesture()
                            .updating($nodeDragOffset) { value, state, _ in
                                state = viewModel.onDragNode(value, node: node)
                            }
                            .onEnded { value in
                                node.position += CGVector(dx: value.translation.width,
                                                          dy: value.translation.height)
                            }
                    )
                )
        }
    }

    func placeholderNodeView(position: CGPoint) -> some View {
        EditorNodeView(viewModel: EditorNodeViewModel(graph: viewModel.graph, node: Node()), selection: selection)
            .position(position)
            .opacity(0.4)
    }
}

 struct EditorGraphView_Previews: PreviewProvider {
    static var previews: some View {
        EditorGraphView(viewModel: EditorGraphViewModel(graph: UnweightedGraph()))
    }
 }
