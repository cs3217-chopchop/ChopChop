import Combine
import Foundation

final class EditorNodeViewModel: ObservableObject {
    @Published var isEditing = false
    @Published var content = ""
    @Published var timers: [TimeInterval] = []
    @Published var showTimers = false

    @Published var alertIsPresented = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    private var graph: RecipeStepGraph
    let node: RecipeStepNode
    let index: Int?
    let isEditable: Bool

    let recipeStepTimersViewModel: RecipeStepTimersViewModel
    private var timersCancellable: AnyCancellable?

    init(graph: RecipeStepGraph, node: RecipeStepNode, isEditable: Bool = true) {
        self.graph = graph
        self.node = node
        self.isEditable = isEditable

        self.content = node.label.content
        self.timers = node.label.timers
        self.index = graph.topologicallySortedNodes.firstIndex(of: node)

        recipeStepTimersViewModel = RecipeStepTimersViewModel(timers: node.label.timers)
        timersCancellable = recipeStepTimersViewModel.timersPublisher
            .sink { [weak self] timers in
                self?.timers = timers
                node.label.timers = timers
            }
    }

    func saveAction() {
        do {
            node.label = try RecipeStep(content, timers: node.label.timers)
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
