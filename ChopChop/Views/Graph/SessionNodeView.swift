import SwiftUI

/**
 Represents a view of a step in the instructions of a recipe being made.
 */
 struct SessionNodeView: View {
    @StateObject var viewModel: SessionNodeViewModel
    @ObservedObject var selection: SelectionHandler<SessionRecipeStepNode>

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

    private var isSelected: Bool {
        selection.isNodeSelected(viewModel.node)
    }

    @ViewBuilder
    private var stepText: some View {
        if let index = viewModel.index {
            Text("Step \(index + 1)")
                .font(.headline)
                .foregroundColor(viewModel.node.isCompleted ? .secondary : .primary)
                .strikethrough(viewModel.node.isCompleted)
        }
    }

    private var nodeView: some View {
        ScrollView(isSelected ? [.vertical] : []) {
            VStack {
                Text(viewModel.node.label.step.content)
                    .strikethrough(viewModel.node.isCompleted)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
            }
        }
    }

    // MARK: - Detail

    private var detailView: some View {
        HStack(spacing: 16) {
            toggleCompleteButton

            if !viewModel.node.isCompletable {
                Text("Previous step has not been completed")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }

            Spacer()

            if !viewModel.node.label.timers.isEmpty {
                scrollToTimersButton
            }
        }
        .padding(.top, 6)
    }

    private var toggleCompleteButton: some View {
        Button(action: {
            withAnimation {
                viewModel.toggleNode()
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
    }

    private var scrollToTimersButton: some View {
        Button(action: {
            withAnimation {
                viewModel.proxy?.scrollTo(viewModel.node, anchor: .top)
            }
        }) {
            Image(systemName: "timer")
        }
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
