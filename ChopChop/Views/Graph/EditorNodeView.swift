import SwiftUI

/**
 Represents a view of a step in the recipe instructions being edited.
 */
struct EditorNodeView: View {
    @StateObject var viewModel: EditorNodeViewModel
    @ObservedObject var selection: SelectionHandler<RecipeStepNode>

    var body: some View {
        TileView(isSelected: isSelected) {
            VStack {
                if let index = viewModel.index {
                    Text("Step \(index + 1)")
                        .font(.headline)
                }

                if viewModel.isEditing {
                    TextEditor(text: $viewModel.content)
                        .transition(.scale)
                } else {
                    ScrollView(isSelected ? [.vertical] : []) {
                        Text(viewModel.node.label.content.isEmpty
                                ? "Add step details..."
                                : viewModel.node.label.content)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                            .foregroundColor(viewModel.node.label.content.isEmpty ? .secondary : .primary)
                    }
                }

                if isSelected {
                    detailView
                        .transition(AnyTransition.scale.combined(with: AnyTransition.move(edge: .top)))
                }
            }
            .padding()
        }
        .overlay(timersView)
        .alert(isPresented: $viewModel.alertIsPresented) {
            Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage))
        }
    }

    private var isSelected: Bool {
        selection.isNodeSelected(viewModel.node)
    }

    // MARK: - Detail

    @ViewBuilder
    private var detailView: some View {
        if viewModel.isEditing {
            isEditingDetailView
        } else {
            isNotEditingDetailView
        }
    }

    private var isEditingDetailView: some View {
        HStack(spacing: 16) {
            Button(action: viewModel.saveAction) {
                Text("Save")
            }
            Spacer()
            Button(action: {
                viewModel.content = viewModel.node.label.content
                viewModel.isEditing = false
            }) {
                Text("Cancel")
            }
        }
        .padding(.top, 6)
    }

    private var isNotEditingDetailView: some View {
        HStack(spacing: 16) {
            if viewModel.isEditable {
                Button(action: {
                    viewModel.isEditing = true
                }) {
                    Image(systemName: "square.and.pencil")
                }
            }

            Button(action: {
                viewModel.showTimers.toggle()
            }) {
                Image(systemName: "timer")
            }
            Spacer()

            if viewModel.isEditable {
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

    // MARK: - Timers

    @ViewBuilder
    private var timersView: some View {
        if isSelected && viewModel.showTimers {
            TileView(isSelected: true,
                     expandedSize: CGSize(width: RecipeStepNode.expandedSize.width / 2,
                                          height: RecipeStepNode.expandedSize.height)) {
                VStack {
                    Text("Timers")
                        .font(.headline)
                        .padding([.top, .leading, .trailing])
                    timersList
                    .padding([.top, .bottom], 4)
                    if viewModel.isEditable {
                        HStack {
                            Spacer()
                            NavigationLink(
                                destination: RecipeStepTimersView(viewModel: viewModel.recipeStepTimersViewModel)
                            ) {
                                Image(systemName: "square.and.pencil")
                            }
                        }
                        .padding([.bottom, .leading, .trailing])
                    }
                }
            }
            .offset(x: RecipeStepNode.expandedSize.width * 0.75 + 32, y: 0)
            .transition(.identity)
        }
    }

    @ViewBuilder
    private var timersList: some View {
        if viewModel.timers.isEmpty {
            Spacer()
            Text("No step timers")
                .foregroundColor(.secondary)
            Spacer()
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.timers, id: \.self) { duration in
                        Text(viewModel.timeFormatter.string(from: duration) ?? "")
                            .padding([.leading, .trailing], 8)
                        Divider()
                            .padding([.top, .bottom], 10)
                    }
                }
                .padding([.leading, .trailing], 8)
            }
        }
    }
}

struct EditorNodeView_Previews: PreviewProvider {
    static var previews: some View {
        if let step = try? RecipeStep("Preview") {
            EditorNodeView(viewModel: EditorNodeViewModel(graph: RecipeStepGraph(),
                                                          node: RecipeStepNode(step)),
                           selection: SelectionHandler())
        }
    }
}
