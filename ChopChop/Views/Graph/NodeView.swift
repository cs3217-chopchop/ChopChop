import SwiftGraph
import SwiftUI

struct NodeView: View {
    static let initialSize = CGSize(width: 120, height: 80)
    static let expandedSize = CGSize(width: 360, height: 240)

    @ObservedObject var selection: SelectionHandler
    @State var isEditing = false
    @State var text = ""
    var node: Node
    let index: Int
    let removeNode: (Node) -> Void

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

                    if isEditing {
                        TextEditor(text: $text)
                            .onTapGesture {
                                print("lol")
                            }
                    } else {
                        ScrollView {
                            Text(node.text)
                                .lineLimit(isSelected ? nil : 1)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                        }
                    }

                    if isSelected {
                        if isEditing {
                            HStack {
                                Button(action: {
                                    node.text = text
                                    isEditing = false
                                }) {
                                    Text("Save")
                                }
                                Spacer()
                                Button(action: {
                                    text = ""
                                    isEditing = false
                                }) {
                                    Text("Cancel")
                                }
                            }
                        } else {
                            HStack {
                                Button(action: {
                                    text = node.text
                                    isEditing = true
                                }) {
                                    Image(systemName: "square.and.pencil")
                                }
                                Spacer()
                                Button(action: {
                                    removeNode(node)
                                    selection.objectWillChange.send()
                                }) {
                                    Image(systemName: "trash")
                                }
                            }
                        }
                    }
                }
                .padding()
            )
            .frame(width: isSelected ? 360 : 120, height: isSelected ? 240 : 80)
            .zIndex(isSelected ? 1 : 0)
    }
}

// struct NodeView_Previews: PreviewProvider {
//    static var previews: some View {
//        NodeView(viewModel: GraphViewModel(), node: Node(position: .zero, text: ""))
//    }
// }
