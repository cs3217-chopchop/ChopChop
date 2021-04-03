import SwiftGraph
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
        NodeView(isSelected: isSelected, isFaded: viewModel.node.isCompleted || !viewModel.node.isCompletable) {
            VStack {
                if viewModel.index != nil {
                    if let index = viewModel.index {
                        Text("Step \(index + 1)")
                            .font(.headline)
                            .foregroundColor(viewModel.node.isCompleted || !viewModel.node.isCompletable
                                                ? .secondary
                                                : .primary)
                            .strikethrough(viewModel.node.isCompleted)
                    }

                    ScrollView(isSelected ? [.vertical] : []) {
                        Text(viewModel.node.label.step.content)
                            .foregroundColor(viewModel.node.isCompleted || !viewModel.node.isCompletable
                                                ? .secondary
                                                : .primary)
                            .strikethrough(viewModel.node.isCompleted)
                            .lineLimit(isSelected ? nil : 1)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                    }

                    if isSelected {
                        detailView
                            .transition(AnyTransition.scale.combined(with: AnyTransition.move(edge: .top)))
                    }
                }
            }
            .padding()
        }
    }

    var detailView: some View {
        HStack {
            Button(action: {
                withAnimation {
                    viewModel.graph.completeStep(viewModel.node)
                    selection.deselectNode(viewModel.node)
                }
            }) {
                Image(systemName: viewModel.node.isCompleted ? "checkmark.square" : "square")
            }
            Spacer()
        }
        .padding(.top, 6)
    }
 }

// struct SessionNodeView_Previews: PreviewProvider {
//    static var previews: some View {
//        SessionNodeView(viewModel: SessionNodeViewModel(graph: UnweightedGraph<Node2>(),
//                                                        node: Node2()),
//                        selection: SelectionHandler())
//    }
// }
