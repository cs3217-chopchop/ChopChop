import SwiftGraph
import SwiftUI

struct SessionNodeView: View {
    @ObservedObject var viewModel: SessionNodeViewModel
    @ObservedObject var selection: SelectionHandler
    @State var isCompleted = false

    var isSelected: Bool {
        selection.isNodeSelected(viewModel.node)
    }

    init(viewModel: SessionNodeViewModel, selection: SelectionHandler) {
        self.viewModel = viewModel
        self.selection = selection

        UITextView.appearance().backgroundColor = .clear
    }

    var body: some View {
        NodeView(isSelected: isSelected, isFaded: isCompleted) {
            VStack {
                if viewModel.index != nil {
                    if let index = viewModel.index {
                        Text("Step \(index + 1)")
                            .font(.headline)
                            .foregroundColor(isCompleted ? .secondary : .primary)
                            .strikethrough(isCompleted)
                    }

                    ScrollView(isSelected ? [.vertical] : []) {
                        Text(viewModel.node.text)
                            .foregroundColor(isCompleted ? .secondary : .primary)
                            .strikethrough(isCompleted)
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
                    isCompleted.toggle()
                    selection.deselectNode(viewModel.node)
                }
            }) {
                Image(systemName: isCompleted ? "checkmark.square" : "square")
            }
            Spacer()
        }
        .padding(.top, 6)
    }
}

 struct SessionNodeView_Previews: PreviewProvider {
    static var previews: some View {
        SessionNodeView(viewModel: SessionNodeViewModel(graph: UnweightedGraph<Node>(),
                                                        node: Node()),
                        selection: SelectionHandler())
    }
 }
