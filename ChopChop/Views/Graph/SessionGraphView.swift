import SwiftUI

 struct SessionGraphView: View {
    @ObservedObject var viewModel: SessionGraphViewModel
    @ObservedObject var selection = SelectionHandler<SessionRecipeStepNode>()

    @GestureState var portalDragOffset = CGVector.zero

    var body: some View {
        ZStack(alignment: .top) {
            linesView

            nodesView(nodes: viewModel.graph.topologicallySortedNodes)

//            if viewModel.showTimerPanel {
//                Rectangle()
//                    .fill(Color(UIColor.systemBackground))
//                    .overlay(Divider(), alignment: .bottom)
//                    .overlay(
//                        ScrollView(.horizontal) {
//                            HStack {
//                                TileView(normalSize: CGSize(width: 160, height: 134)) {
//                                    VStack {
//                                        Text("Step 1")
//                                            .font(.headline)
//                                        Text("ola")
//                                    }
//                                }
//                                TileView(normalSize: CGSize(width: 160, height: 134)) {
//                                    VStack {
//                                        Text("Step 2")
//                                            .font(.headline)
//                                        Text("ola")
//                                    }
//                                }
//                            }
//                            .padding()
//                        }
//                        .background(Color.orange)
//                    )
//                    .frame(height: 160)
//                    .transition(AnyTransition.move(edge: .top))
//                    .zIndex(1)
//            }
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
        .gesture(
            DragGesture()
                .updating($portalDragOffset) { value, state, _ in
                    state = CGVector(dx: value.translation.width, dy: value.translation.height)
                }
                .onEnded(viewModel.onDragPortal)
        )
//        .toolbar {
//            Button(action: {
//                withAnimation {
//                    viewModel.showTimerPanel.toggle()
//                }
//            }) {
//                HStack {
//                    Image(systemName: "timer")
//                }
//            }
//        }
    }

    var linesView: some View {
        ForEach(viewModel.graph.edges, id: \.self) { edge in
            Line(from: (edge.source.position ?? .zero)
                    + viewModel.portalPosition + portalDragOffset,
                 to: (edge.destination.position ?? .zero)
                    + viewModel.portalPosition + portalDragOffset)
                .stroke(Color.primary, lineWidth: 1.8)
        }
    }

    func nodesView(nodes: [SessionRecipeStepNode]) -> some View {
        ForEach(nodes) { node in
            SessionNodeView(viewModel: SessionNodeViewModel(graph: viewModel.graph, node: node), selection: selection)
                .position((node.position ?? .zero) + viewModel.portalPosition + portalDragOffset)
                .onTapGesture {
                    withAnimation {
                        selection.toggleNode(node)
                    }
                }
        }
    }
 }

struct SessionGraphView_Previews: PreviewProvider {
    static var previews: some View {
        if let graph = SessionRecipeStepGraph(graph: RecipeStepGraph()) {
            SessionGraphView(viewModel: SessionGraphViewModel(graph: graph))
        }
    }
}
