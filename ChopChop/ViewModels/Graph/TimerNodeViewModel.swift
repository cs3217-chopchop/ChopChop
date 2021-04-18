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
            timer.$status
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
