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

            nodesView(nodes: viewModel.graph.getTopologicallySortedNodes())

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
        ForEach(viewModel.graph.edges, id: \.self) { edge in
            if let offset = nodeDragOffset {
                Line(from: (edge.source.position ?? .zero)
                        + viewModel.portalPosition + portalDragOffset
                        + (edge.source.id == offset.id ? offset.offset : .zero),
                     to: (edge.destination.position ?? .zero)
                        + viewModel.portalPosition + portalDragOffset
                        + (edge.destination.id == offset.id ? offset.offset : .zero))
                    .stroke(Color.primary, lineWidth: 1.8)
            } else {
                Line(from: (edge.source.position ?? .zero)
                        + viewModel.portalPosition + portalDragOffset,
                     to: (edge.destination.position ?? .zero)
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

    func nodesView(nodes: [RecipeStepNode]) -> some View {
        ForEach(nodes) { node in
            EditorNodeView(viewModel: EditorNodeViewModel(graph: viewModel.graph, node: node), selection: selection)
                .position((node.position ?? .zero) + viewModel.portalPosition + portalDragOffset
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
                                guard let position = node.position else {
                                    return
                                }

                                state = viewModel.onLongPressDragNode(value, position: position)
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
                                guard let position = node.position else {
                                    return
                                }

                                node.position = position + CGVector(dx: value.translation.width,
                                                                    dy: value.translation.height)
                            }
                    )
                )
        }
    }

    func placeholderNodeView(position: CGPoint) -> some View {
        guard let step = try? RecipeStep(content: "Add step details...") else {
            return AnyView(EmptyView())
        }

        return AnyView(EditorNodeView(viewModel: EditorNodeViewModel(graph: viewModel.graph,
                                                                     node: RecipeStepNode(step)),
                       selection: selection)
            .position(position)
            .opacity(0.4))
    }
}

 struct EditorGraphView_Previews: PreviewProvider {
    static var previews: some View {
        EditorGraphView(viewModel: EditorGraphViewModel(graph: RecipeStepGraph()))
    }
 }
