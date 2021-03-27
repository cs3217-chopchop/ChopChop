import SwiftGraph
import SwiftUI

struct GraphView: View {
    @ObservedObject var selection: SelectionHandler
    var graph: UnweightedGraph<Node>
    var offset: CGVector

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(graph.edgeList(), id: \.description) { edge in
                Line(from: graph.vertexAtIndex(edge.u).position + offset,
                     to: graph.vertexAtIndex(edge.v).position + offset)
                    .stroke(Color.blue, lineWidth: 3)
            }

            if let nodes = graph.topologicalSort() {
                ForEach(nodes.indices) { index in
                    NodeView(selection: selection, node: nodes[index], index: index + 1)
                        .position(nodes[index].position + offset)
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
    }
}

// struct GraphView_Previews: PreviewProvider {
//    static var previews: some View {
//        GraphView(viewModel: GraphViewModel())
//    }
// }
