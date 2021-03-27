import SwiftUI

struct GraphView: View {
    @ObservedObject var viewModel: GraphViewModel
    @ObservedObject var selection = SelectionHandler()

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(viewModel.graph.edgeList(), id: \.description) { edge in
                Line(from: viewModel.graph.vertexAtIndex(edge.u).position,
                     to: viewModel.graph.vertexAtIndex(edge.v).position)
                    .stroke(Color.blue, lineWidth: 3)
            }

            if let nodes = viewModel.graph.topologicalSort() {
                ForEach(nodes.indices) { index in
                    NodeView(selection: selection, node: nodes[index], index: index + 1)
                        .position(x: nodes[index].position.x, y: nodes[index].position.y)
                        .onTapGesture {
                            selection.toggleNode(nodes[index])
                        }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selection.unselectAllNodes()
        }
        .background(Color.orange)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}

struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        GraphView(viewModel: GraphViewModel())
    }
}
