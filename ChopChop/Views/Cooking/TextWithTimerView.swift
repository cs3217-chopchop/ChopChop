import SwiftUI

struct TextWithTimerView: View {
    @ObservedObject var viewModel: SessionRecipeStepViewModel
    let text: String
    @ObservedObject var timer: CountdownTimerViewModel

    var body: some View {
        Text(text)
            .foregroundColor(viewModel.isCompleted ? .gray : .blue)
            .strikethrough(viewModel.isCompleted, color: nil)
            .lineLimit(1)
            .onTapGesture { timer.toggleShow() }
            .background(EmptyView().popover(isPresented: $timer.isShow, arrowEdge: .top) {
                ZStack {
                    Color.gray.scaleEffect(1.5)
                    CountdownTimerView(viewModel: timer)
                        .padding()
                }
            })

    }
}

 struct TextWithTimer_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable force_try line_length
        TextWithTimerView(viewModel: SessionRecipeStepViewModel(sessionRecipeStep: SessionRecipeStep(step: try! RecipeStep(content: "Step 1"), actionTimeTracker: ActionTimeTracker())), text: "30 mins", timer: CountdownTimerViewModel(countdownTimer: try! CountdownTimer(time: 1_800)))
    }
 }
