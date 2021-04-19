import Combine
import SwiftUI

final class TimerNodeViewModel: ObservableObject {
    var graph: SessionRecipeStepGraph
    let node: SessionRecipeStepNode
    let index: Int?

    let proxy: ScrollViewProxy?
    var cancellables = Set<AnyCancellable>()

    var hasTimers: Bool {
        !node.label.timers.isEmpty
    }

    init(graph: SessionRecipeStepGraph, node: SessionRecipeStepNode, proxy: ScrollViewProxy? = nil) {
        self.graph = graph
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
}
