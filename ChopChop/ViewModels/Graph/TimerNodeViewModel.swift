import Combine

final class TimerNodeViewModel: ObservableObject {
    @Published var textWithTimers: [(String, CountdownTimer?)] = []
    var graph: SessionRecipeStepGraph
    let node: SessionRecipeStepNode
    let index: Int?

    var hasTimers: Bool {
        !textWithTimers.allSatisfy { $0.1 == nil }
    }

    init(graph: SessionRecipeStepGraph, node: SessionRecipeStepNode) {
        self.graph = graph
        self.node = node
        self.index = graph.topologicallySortedNodes.firstIndex(of: node)

        textWithTimers = createTextWithTimers(sessionRecipeStep: node.label)
    }

    /// Breaks up the contents of a step to an array of tuple containing substring of the content
    /// and an optional CountdownTimerViewModel
    /// E.g. "Cook for 30s until the edges are dry and bubbles appear on surface.
    /// Flip; cook for 1 to 2 minutes. Yields 12 to 14 pancakes." into
    /// [("Cook for", nil), ("30s", timer),
    /// ("until the edges are dry and bubbles appear on surface. Flip; cook for ", nil),
    /// ("1 to 2 minutes", timer), (". Yields 12 to 14 pancakes.", nil)]"
    private func createTextWithTimers(sessionRecipeStep: SessionRecipeStep) -> [(String, CountdownTimer?)] {
        let splitStepContentBy = sessionRecipeStep.timers.map { $0.0 }
        let splittedStepContent = sessionRecipeStep.step.content
            .componentsSeperatedByStrings(separators: splitStepContentBy)
        var stringsToTimers: [(String, CountdownTimer?)] = []
        var timerIdx = 0
        for substring in splittedStepContent {
            guard sessionRecipeStep.timers.contains(where: { $0.0 == substring }) else {
                // no timer associated with substring
                stringsToTimers.append((substring, nil))
                continue
            }
            // has timer associated with substring
            stringsToTimers.append((substring, sessionRecipeStep.timers[timerIdx].1))
            timerIdx += 1
        }
        assert(timerIdx == sessionRecipeStep.timers.count)
        return stringsToTimers
    }
}
