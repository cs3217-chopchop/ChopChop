import Combine
import SwiftUI

/**
 Represents a view model of a view of a collection of timers in an instruction step.
 */
final class TimerNodeViewModel: ObservableObject {
    /// The step that owns the collection of timers displayed in the view.
    let node: SessionRecipeStepNode
    /// The index of the step.
    let index: Int?

    private let proxy: ScrollViewProxy?
    private var cancellables = Set<AnyCancellable>()

    init(graph: SessionRecipeStepGraph, node: SessionRecipeStepNode, proxy: ScrollViewProxy? = nil) {
        self.node = node
        self.index = graph.topologicallySortedNodes.firstIndex(of: node)
        self.proxy = proxy

        for timer in node.label.timers {
            // The status publisher publishes the initial state upon first subscription,
            // so if the first status is not dropped, it will try to scroll to the timer
            // if it has ended, leading to a crash as it tries to scroll while the timer
            // panel is being animated in.
            timer.$status.dropFirst()
                .sink { [weak self] status in
                    guard status == .ended else {
                        return
                    }

                    withAnimation {
                        self?.proxy?.scrollTo(timer)
                    }
                }
                .store(in: &cancellables)
        }
    }

    var timers: [CountdownTimer] {
        node.label.timers
    }

    var hasTimers: Bool {
        !node.label.timers.isEmpty
    }
}
