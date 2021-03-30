import SwiftGraph
import SwiftUI

struct EditorNodeView: View {
    @ObservedObject var viewModel: EditorNodeViewModel
    @ObservedObject var selection: SelectionHandler

    var isSelected: Bool {
        selection.isNodeSelected(viewModel.node)
    }

    init(viewModel: EditorNodeViewModel, selection: SelectionHandler) {
        self.viewModel = viewModel
        self.selection = selection

        UITextView.appearance().backgroundColor = .clear
    }

    var body: some View {
        NodeView(isSelected: isSelected) {
            VStack {
                if viewModel.index != nil {
                    if let index = viewModel.index {
                        Text("Step \(index + 1)")
                            .font(.headline)
                    }

                    if viewModel.isEditing {
                        TextEditor(text: $viewModel.text)
                            .background(Color.primary.opacity(0.1))
                            .transition(.scale)
                            // Prevent taps from propogating
                            .onTapGesture {}
                    } else {
                        ScrollView(isSelected ? [.vertical] : []) {
                            Text(viewModel.node.text.isEmpty ? "Add step details..." : viewModel.node.text)
                                .lineLimit(isSelected ? nil : 1)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                                .foregroundColor(viewModel.node.text.isEmpty ? .secondary : .primary)
                        }
                    }

                    if isSelected {
                        detailView
                            .transition(AnyTransition.scale
                                            .combined(with: AnyTransition.move(edge: .top)))
                    }
                }
            }
            .padding()
        }
    }

    var detailView: some View {
        HStack {
            if viewModel.isEditing {
                Button(action: {
                    viewModel.node.text = viewModel.text
                    viewModel.isEditing = false
                }) {
                    Text("Save")
                }
                Spacer()
                Button(action: {
                    viewModel.text = viewModel.node.text
                    viewModel.isEditing = false
                }) {
                    Text("Cancel")
                }
            } else {
                Button(action: {
                    viewModel.isEditing = true
                }) {
                    Image(systemName: "square.and.pencil")
                }
                Spacer()
                Button(action: {
                    viewModel.removeNode()
                    selection.toggleNode(viewModel.node)
                }) {
                    Image(systemName: "trash")
                }
            }
        }
        .padding(.top, 6)
    }
}

 struct EditorNodeView_Previews: PreviewProvider {
    static var previews: some View {
        EditorNodeView(viewModel: EditorNodeViewModel(graph: UnweightedGraph<Node>(),
                                                      node: Node()),
                       selection: SelectionHandler())
    }
 }
