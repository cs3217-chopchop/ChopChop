import Combine

final class EditorNodeViewModel: ObservableObject {
    @Published var isEditing = false
    @Published var text = ""

    @Published var alertIsPresented = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    private var graph: RecipeStepGraph
    let node: RecipeStepNode
    let index: Int?
    let isEditable: Bool

    init(graph: RecipeStepGraph, node: RecipeStepNode, isEditable: Bool = true) {
        self.graph = graph
        self.node = node
        self.isEditable = isEditable

        self.text = node.label.content
        self.index = graph.topologicallySortedNodes.firstIndex(of: node)
    }

    func saveAction() {
        do {
            try node.label.updateContent(text)
            isEditing = false
        } catch {
            guard let message = (error as? RecipeStepError)?.rawValue else {
                return
            }

            alertTitle = "Error"
            alertMessage = message
            alertIsPresented = true
        }
    }

    func removeNode() {
        graph.removeNode(node)
    }
}
