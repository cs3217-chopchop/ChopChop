import SwiftGraph
import SwiftUI

struct NodeView: View {
    @ObservedObject var viewModel: NodeViewModel
    @ObservedObject var selection: SelectionHandler

    var isSelected: Bool {
        selection.isNodeSelected(viewModel.node)
    }

    init(viewModel: NodeViewModel, selection: SelectionHandler) {
        self.viewModel = viewModel
        self.selection = selection

        UITextView.appearance().backgroundColor = .clear
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(Color.accentColor)
            .shadow(color: isSelected ? .accentColor : .clear, radius: 6)
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(UIColor.systemBackground).opacity(0.8))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(Color.accentColor, lineWidth: 1.5)
            )
            .overlay(
                VStack {
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
                            Text(viewModel.node.text)
                                .lineLimit(isSelected ? nil : 1)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                        }
                    }

                    if isSelected {
                        detailView
                            .transition(AnyTransition.scale
                                            .combined(with: AnyTransition.move(edge: .top)))
                    }
                }
                .padding()
            )
            .frame(width: isSelected ? 360 : 120, height: isSelected ? 240 : 84)
            .zIndex(isSelected ? 1 : 0)
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

 struct NodeView_Previews: PreviewProvider {
    static var previews: some View {
        NodeView(viewModel: NodeViewModel(graph: UnweightedGraph<Node>(),
                                          node: Node()),
                 selection: SelectionHandler())
    }
 }
