import Combine
import SwiftGraph

final class EditorNodeViewModel: ObservableObject {
    @Published var isEditing = false
    @Published var text = ""

    @Published var alertIsPresented = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    private var graph: RecipeStepGraph
    let node: RecipeStepNode
    let index: Int?

    init(graph: RecipeStepGraph, node: RecipeStepNode) {
        self.graph = graph
        self.node = node

        self.text = node.label.content
        self.index = graph.getTopologicallySortedNodes().firstIndex(of: node)
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
