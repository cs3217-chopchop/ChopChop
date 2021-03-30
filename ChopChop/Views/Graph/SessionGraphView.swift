import SwiftGraph
import SwiftUI

struct SessionGraphView: View {
    @ObservedObject var viewModel: SessionGraphViewModel
    @ObservedObject var selection = SelectionHandler()

    @GestureState var portalDragOffset = CGVector.zero

    var body: some View {
        ZStack {
            linesView

            if let nodes = viewModel.graph.topologicalSort() {
                nodesView(nodes: nodes)
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
            DragGesture()
                .updating($portalDragOffset) { value, state, _ in
                    state = CGVector(dx: value.translation.width, dy: value.translation.height)
                }
                .onEnded(viewModel.onDragPortal)
        )
    }

    var linesView: some View {
        ForEach(viewModel.graph.edgeList(), id: \.self) { edge in
            Line(from: viewModel.graph.vertexAtIndex(edge.u).position
                    + viewModel.portalPosition + portalDragOffset,
                 to: viewModel.graph.vertexAtIndex(edge.v).position
                    + viewModel.portalPosition + portalDragOffset)
                .stroke(Color.primary, lineWidth: 1.8)
        }
    }

    func nodesView(nodes: [Node]) -> some View {
        ForEach(nodes) { node in
            SessionNodeView(viewModel: SessionNodeViewModel(graph: viewModel.graph, node: node), selection: selection)
                .position(node.position + viewModel.portalPosition + portalDragOffset)
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
        SessionGraphView(viewModel: SessionGraphViewModel(graph: UnweightedGraph()))
    }
 }
