import SwiftGraph
import SwiftUI

struct GraphView: View {
    @ObservedObject var selection: SelectionHandler
    var graph: UnweightedGraph<Node>

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(graph.edgeList(), id: \.description) { edge in
                Line(from: graph.vertexAtIndex(edge.u).position,
                     to: graph.vertexAtIndex(edge.v).position)
                    .stroke(Color.blue, lineWidth: 3)
            }

            if let nodes = graph.topologicalSort() {
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
//        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}

// struct GraphView_Previews: PreviewProvider {
//    static var previews: some View {
//        GraphView(viewModel: GraphViewModel())
//    }
// }
