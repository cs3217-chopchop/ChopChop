import Combine
import Foundation

final class EditorNodeViewModel: ObservableObject {
    @Published var isEditing = false
    @Published var text = ""
    @Published var showTimers = false

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
            node.label = try RecipeStep(text)
            isEditing = false
        } catch {
            alertTitle = "Error"

            if let message = (error as? LocalizedError)?.errorDescription {
                alertMessage = message
            } else {
                alertMessage = "\(error)"
            }

            alertIsPresented = true
        }
    }

    func removeNode() {
        graph.removeNode(node)
    }
}
