import SwiftUI

/**
 Represents a view of the recipe instructions being edited.
 */
struct EditorGraphView: View {
    @StateObject var viewModel: EditorGraphViewModel
    @StateObject var selection = SelectionHandler<RecipeStepNode>()

    @GestureState var portalDragOffset = CGVector.zero
    @GestureState var nodeDragOffset: EditorGraphViewModel.NodeDragInfo?
    @GestureState var lineDragInfo: EditorGraphViewModel.LineDragInfo?
    @GestureState var placeholderNodePosition: CGPoint?

    var body: some View {
        ZStack {
            linesView

            if let info = lineDragInfo, viewModel.isEditable {
                placeholderLineView(info: info)
            }

            nodesView(nodes: viewModel.graph.topologicallySortedNodes)

            if let position = placeholderNodePosition, viewModel.isEditable {
                placeholderNodeView(position: position)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .contentShape(Rectangle())
        .clipped()
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            withAnimation {
                selection.deselectAllNodes()
            }
        }
        .gesture(gesture)
    }

    // MARK: - Lines

    private var linesView: some View {
        ForEach(viewModel.graph.edges, id: \.self) { edge in
            Line(from: (edge.source.position ?? .zero)
                    + viewModel.portalPosition + portalDragOffset
                    + (edge.source.id == nodeDragOffset?.id ? nodeDragOffset?.offset ?? .zero : .zero),
                 to: (edge.destination.position ?? .zero)
                    + viewModel.portalPosition + portalDragOffset
                    + (edge.destination.id == nodeDragOffset?.id ? nodeDragOffset?.offset ?? .zero : .zero))
                .stroke(Color.primary, lineWidth: 1.8)
                .onLongPressGesture {
                    viewModel.graph.removeEdge(edge)
                    viewModel.objectWillChange.send()
                }
        }
    }

    private func placeholderLineView(info: EditorGraphViewModel.LineDragInfo) -> some View {
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

    // MARK: - Nodes

    private func nodesView(nodes: [RecipeStepNode]) -> some View {
        ForEach(nodes) { node in
            EditorNodeView(viewModel: EditorNodeViewModel(graph: viewModel.graph,
                                                          node: node,
                                                          isEditable: viewModel.isEditable),
                           selection: selection)
                .position((node.position ?? .zero) + viewModel.portalPosition + portalDragOffset
                            + (nodeDragOffset?.id == node.id ? nodeDragOffset?.offset ?? .zero : .zero))
                .onTapGesture {
                    withAnimation {
                        selection.selectNode(node)
                    }
                }
                .gesture(getNodeGesture(node))
        }
    }

    private func placeholderNodeView(position: CGPoint) -> some View {
        guard let step = try? RecipeStep("Add step details...") else {
            return AnyView(EmptyView())
        }

        return AnyView(EditorNodeView(viewModel: EditorNodeViewModel(graph: viewModel.graph,
                                                                     node: RecipeStepNode(step)),
                       selection: selection)
            .position(position)
            .opacity(0.4))
    }

    // MARK: - Gestures

    private func getNodeGesture(_ node: RecipeStepNode) -> some Gesture {
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
    }

    private var gesture: some Gesture {
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
    }
}

 struct EditorGraphView_Previews: PreviewProvider {
    static var previews: some View {
        EditorGraphView(viewModel: EditorGraphViewModel(graph: RecipeStepGraph()))
    }
 }
