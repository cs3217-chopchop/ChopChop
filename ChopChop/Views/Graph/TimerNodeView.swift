import SwiftUI

struct TimerNodeView: View {
    @ObservedObject var viewModel: TimerNodeViewModel

    var body: some View {
        if viewModel.hasTimers {
            VStack {
                if let index = viewModel.index {
                    Text("Step \(index + 1)")
                        .font(.headline)
                        .padding([.top, .bottom], 8)
                }

                ForEach(viewModel.node.label.timers, id: \.self) { timer in
                    CountdownTimerView(viewModel: CountdownTimerViewModel(timer: timer))
                }
            }
        } else {
            EmptyView()
        }
    }
}

 struct TimerNodeView_Previews: PreviewProvider {
    static var previews: some View {
        if let step = try? RecipeStep("Preview") {
            TimerNodeView(viewModel:
                            TimerNodeViewModel(graph: SessionRecipeStepGraph(),
                                               node: SessionRecipeStepNode(node: RecipeStepNode(step))))
        }
    }
 }
