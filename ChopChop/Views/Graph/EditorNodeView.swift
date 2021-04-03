import SwiftUI

struct EditorNodeView: View {
    @ObservedObject var viewModel: EditorNodeViewModel
    @ObservedObject var selection: SelectionHandler<RecipeStepNode>

    var isSelected: Bool {
        selection.isNodeSelected(viewModel.node)
    }

    init(viewModel: EditorNodeViewModel, selection: SelectionHandler<RecipeStepNode>) {
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
                            Text(viewModel.node.label.content.isEmpty
                                    ? "Add step details..."
                                    : viewModel.node.label.content)
                                .lineLimit(isSelected ? nil : 1)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                                .foregroundColor(viewModel.node.label.content.isEmpty ? .secondary : .primary)
                        }
                    }

                    if isSelected && viewModel.isEditable {
                        detailView
                            .transition(AnyTransition.scale.combined(with: AnyTransition.move(edge: .top)))
                    }
                }
            }
            .padding()
        }
        .alert(isPresented: $viewModel.alertIsPresented) {
            Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage))
        }
    }

    var detailView: some View {
        HStack {
            if viewModel.isEditing {
                Button(action: viewModel.saveAction) {
                    Text("Save")
                }
                Spacer()
                Button(action: {
                    viewModel.text = viewModel.node.label.content
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
        if let step = try? RecipeStep(content: "#") {
            EditorNodeView(viewModel: EditorNodeViewModel(graph: RecipeStepGraph(),
                                                          node: RecipeStepNode(step)),
                           selection: SelectionHandler())
        }
    }
}
