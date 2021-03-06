import SwiftUI

/**
 Represents a view of the graph display of the instructions of a recipe being made.
 */
struct SessionGraphView: View {
    @StateObject var viewModel: SessionGraphViewModel
    @StateObject var selection = SelectionHandler<SessionRecipeStepNode>()

    @GestureState var portalDragOffset = CGVector.zero

    var body: some View {
        ZStack(alignment: .top) {
            linesView
            nodesView(nodes: viewModel.graph.topologicallySortedNodes)
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

    private var linesView: some View {
        ForEach(viewModel.graph.edges, id: \.self) { edge in
            Line(from: (edge.source.position ?? .zero)
                    + viewModel.portalPosition + portalDragOffset,
                 to: (edge.destination.position ?? .zero)
                    + viewModel.portalPosition + portalDragOffset)
                .stroke(Color.primary, lineWidth: 1.8)
        }
    }

    private func nodesView(nodes: [SessionRecipeStepNode]) -> some View {
        ForEach(nodes) { node in
            SessionNodeView(viewModel: SessionNodeViewModel(graph: viewModel.graph, node: node, proxy: viewModel.proxy),
                            selection: selection)
                .position((node.position ?? .zero) + viewModel.portalPosition + portalDragOffset)
                .onTapGesture {
                    withAnimation {
                        selection.selectNode(node)
                    }
                }
        }
    }

    private var gesture: some Gesture {
        DragGesture()
            .updating($portalDragOffset) { value, state, _ in
                state = CGVector(dx: value.translation.width, dy: value.translation.height)
            }
            .onEnded(viewModel.onDragPortal)
    }
 }

struct SessionGraphView_Previews: PreviewProvider {
    static var previews: some View {
        if let graph = try? SessionRecipeStepGraph(graph: RecipeStepGraph()) {
            SessionGraphView(viewModel: SessionGraphViewModel(graph: graph))
        }
    }
}
