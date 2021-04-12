import SwiftUI

 struct SessionNodeView: View {
    @ObservedObject var viewModel: SessionNodeViewModel
    @ObservedObject var selection: SelectionHandler<SessionRecipeStepNode>

    var isSelected: Bool {
        selection.isNodeSelected(viewModel.node)
    }

    init(viewModel: SessionNodeViewModel, selection: SelectionHandler<SessionRecipeStepNode>) {
        self.viewModel = viewModel
        self.selection = selection

        UITextView.appearance().backgroundColor = .clear
    }

    var body: some View {
        TileView(isSelected: isSelected, isFaded: viewModel.node.isCompleted) {
            VStack {
                if let index = viewModel.index {
                    Text("Step \(index + 1)")
                        .font(.headline)
                        .foregroundColor(viewModel.node.isCompleted ? .secondary : .primary)
                        .strikethrough(viewModel.node.isCompleted)
                }

                ScrollView(isSelected ? [.vertical] : []) {
                    VStack {
                        Text(viewModel.node.label.step.content)
                            .strikethrough(viewModel.node.isCompleted)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                    }
                }

                if isSelected {
                    detailView
                        .transition(AnyTransition.scale.combined(with: AnyTransition.move(edge: .top)))
                }
            }
            .padding()
        }
    }

    var detailView: some View {
        HStack {
            Button(action: {
                withAnimation {
                    viewModel.graph.toggleStep(viewModel.node)
                    selection.deselectNode(viewModel.node)
                }
            }) {
                Image(systemName: viewModel.node.isCompleted
                        ? "checkmark.square"
                        : viewModel.node.isCompletable
                            ? "square"
                            : "square.slash")
            }
            .disabled(!viewModel.node.isCompletable)

            if !viewModel.node.isCompletable {
                Text("Previous step has not been completed")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }

            Spacer()
        }
        .padding(.top, 6)
    }
 }

struct SessionNodeView_Previews: PreviewProvider {
    static var previews: some View {
        if let step = try? RecipeStepNode(RecipeStep("#")),
           let graph = SessionRecipeStepGraph(graph: RecipeStepGraph()) {
            SessionNodeView(viewModel:
                                SessionNodeViewModel(graph: graph,
                                                     node: SessionRecipeStepNode(step,
                                                                                 actionTimeTracker: ActionTimeTracker())),
                            selection: SelectionHandler())
        }
    }
}
