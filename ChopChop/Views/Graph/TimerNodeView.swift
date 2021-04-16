import SwiftUI

struct TimerNodeView: View {
    @ObservedObject var viewModel: TimerNodeViewModel

    let rows = [
        GridItem(),
        GridItem()
    ]

    var body: some View {
        if viewModel.hasTimers {
            HStack {
                if let index = viewModel.index {
                    TileView(normalSize: CGSize(width: 80, height: 134)) {
                        VStack {
                            Text("Step")
                            Text("\(index + 1)")
                        }
                        .font(.headline)
                    }
                }

                LazyHGrid(rows: rows) {
                    ForEach(viewModel.node.label.timers, id: \.self) { timer in
                        CountdownTimerView(viewModel: CountdownTimerViewModel(countdownTimer: timer))
                            .padding()
                    }
                }
            }
        } else {
            EmptyView()
        }
    }
}

 struct TimerNodeView_Previews: PreviewProvider {
    static var previews: some View {
        if let step = try? RecipeStep("#") {
            TimerNodeView(viewModel:
                            TimerNodeViewModel(graph: SessionRecipeStepGraph(),
                                               node: SessionRecipeStepNode(RecipeStepNode(step),
                                                                           actionTimeTracker: ActionTimeTracker())))
        }
    }
 }
