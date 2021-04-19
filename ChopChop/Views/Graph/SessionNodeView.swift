import SwiftUI

 struct SessionNodeView: View {
    @StateObject var viewModel: SessionNodeViewModel
    @ObservedObject var selection: SelectionHandler<SessionRecipeStepNode>

    var isSelected: Bool {
        selection.isNodeSelected(viewModel.node)
    }

    var body: some View {
        TileView(isSelected: isSelected, isFaded: viewModel.node.isCompleted) {
            VStack {
                stepText
                nodeView

                if isSelected {
                    detailView
                        .transition(AnyTransition.scale.combined(with: AnyTransition.move(edge: .top)))
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    var stepText: some View {
        if let index = viewModel.index {
            Text("Step \(index + 1)")
                .font(.headline)
                .foregroundColor(viewModel.node.isCompleted ? .secondary : .primary)
                .strikethrough(viewModel.node.isCompleted)
        }
    }

    var nodeView: some View {
        ScrollView(isSelected ? [.vertical] : []) {
            VStack {
                Text(viewModel.node.label.step.content)
                    .strikethrough(viewModel.node.isCompleted)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
            }
        }
    }

    var detailView: some View {
        HStack(spacing: 16) {
            Button(action: {
                withAnimation {
                    viewModel.graph.toggleNode(viewModel.node)
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

            if !viewModel.node.label.timers.isEmpty {
                Button(action: {
                    withAnimation {
                        viewModel.proxy?.scrollTo(viewModel.node, anchor: .top)
                    }
                }) {
                    Image(systemName: "timer")
                }
            }
        }
        .padding(.top, 6)
    }
 }

struct SessionNodeView_Previews: PreviewProvider {
    static var previews: some View {
        if let node = try? RecipeStepNode(RecipeStep("Preview")),
           let graph = try? SessionRecipeStepGraph(graph: RecipeStepGraph()) {
            SessionNodeView(
                viewModel: SessionNodeViewModel(
                    graph: graph,
                    node: SessionRecipeStepNode(node: node)),
                        selection: SelectionHandler())
        }
    }
}
