import Combine
import Foundation

/**
 Represents a view model of a view of a step in the recipe instructions being edited.
 */
final class EditorNodeViewModel: ObservableObject {
    /// The step displayed in the view.
    let node: RecipeStepNode
    /// The index of the step.
    let index: Int?
    /// A flag representing whether the step can be edited or is only for display.
    let isEditable: Bool
    /// The graph that the step belongs to.
    private var graph: RecipeStepGraph

    /// Form fields
    @Published var content = ""
    @Published var timers: [TimeInterval] = []

    /// Display flags
    @Published var isEditing = false
    @Published var showTimers = false

    /// Alert fields
    @Published var alertIsPresented = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    let timeFormatter: DateComponentsFormatter
    let recipeStepTimersViewModel: RecipeStepTimersViewModel
    private var cancellables: Set<AnyCancellable> = []

    init(graph: RecipeStepGraph, node: RecipeStepNode, isEditable: Bool = true) {
        self.graph = graph
        self.node = node
        self.isEditable = isEditable

        timeFormatter = DateComponentsFormatter()
        timeFormatter.allowedUnits = [.hour, .minute, .second]
        timeFormatter.zeroFormattingBehavior = .pad

        self.content = node.label.content
        self.timers = node.label.timers
        self.index = graph.topologicallySortedNodes.firstIndex(of: node)

        recipeStepTimersViewModel = RecipeStepTimersViewModel(node: node, timers: node.label.timers)
        recipeStepTimersViewModel.timersPublisher
            .sink { [weak self] timers in
                guard let step = try? RecipeStep(node.label.content, timers: timers) else {
                    return
                }

                self?.timers = timers
                node.label = step
            }
            .store(in: &cancellables)
    }

    /**
     Updates the step in the graph with the information in the form fields,
     or updates the alert fields if at least one of the fields is invalid.
     */
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

    /**
     Removes this step from the graph.
     */
    func removeNode() {
        graph.removeNode(node)
    }
}
