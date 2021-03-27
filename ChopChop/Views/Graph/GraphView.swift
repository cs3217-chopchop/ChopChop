import SwiftGraph
import SwiftUI

struct GraphView: View {
    @ObservedObject var selection: SelectionHandler
    var graph: UnweightedGraph<Node>
    var offset: CGVector
    @State var dragOffset: CGSize = .zero
    @State var selectedNode: Node?

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(graph.edgeList(), id: \.description) { edge in
                Line(from: graph.vertexAtIndex(edge.u).position + offset
                        + (selectedNode == graph.vertexAtIndex(edge.u)
                            ? CGVector(dx: dragOffset.width, dy: dragOffset.height) : .zero),
                     to: graph.vertexAtIndex(edge.v).position + offset
                        + (selectedNode == graph.vertexAtIndex(edge.v)
                            ? CGVector(dx: dragOffset.width, dy: dragOffset.height) : .zero))
                    .stroke(Color.blue, lineWidth: 3)
            }

            if let nodes = graph.topologicalSort() {
                ForEach(nodes) { node in
                    NodeView(selection: selection, node: node, index: 1)
                        .position(node.position + offset
                                    + (selectedNode == node
                                        ? CGVector(dx: dragOffset.width, dy: dragOffset.height)
                                        : .zero))
                        .onTapGesture {
                            selection.toggleNode(node)
                        }
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    dragOffset = value.translation
                                    selectedNode = node
                                }
                                .onEnded { value in
                                    dragOffset = .zero
                                    selectedNode = nil
                                    node.position += CGVector(dx: value.translation.width,
                                                              dy: value.translation.height)
                                }
                        )
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
