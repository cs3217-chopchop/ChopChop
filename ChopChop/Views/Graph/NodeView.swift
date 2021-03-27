import SwiftUI

struct NodeView: View {
    static let initialSize = CGSize(width: 120, height: 80)
    static let expandedSize = CGSize(width: 360, height: 240)

    @ObservedObject var selection: SelectionHandler
    @State var node: Node
    let index: Int

    var isSelected: Bool {
        selection.isNodeSelected(node)
    }

    var body: some View {
        Rectangle()
            .fill(Color.green)
            .overlay(
                Rectangle()
                    .stroke(isSelected ? Color.red : Color.white, lineWidth: isSelected ? 5 : 3)
            )
            .overlay(
                VStack {
                    Text("Step \(index)")
                        .font(.headline)

                    ScrollView {
                        Text(node.text)
                            .lineLimit(isSelected ? nil : 1)
                    }
                }
                .padding()
            )
            .frame(width: isSelected ? 360 : 120, height: isSelected ? 240 : 80)
            .zIndex(isSelected ? 1 : 0)
            .animation(.default)
    }
}

// struct NodeView_Previews: PreviewProvider {
//    static var previews: some View {
//        NodeView(viewModel: GraphViewModel(), node: Node(position: .zero, text: ""))
//    }
// }
