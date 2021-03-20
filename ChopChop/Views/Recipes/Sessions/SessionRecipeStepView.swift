import SwiftUI

struct SessionRecipeStepView: View {
    @ObservedObject var viewModel: SessionRecipeStepViewModel

    var body: some View {
        Toggle(isOn: $viewModel.isCompleted) {
//            ZStack {
                ForEach(viewModel.textWithTimers, id: \.0) { text, timer in
                    if let countdownTimer = timer {
                        VStack(alignment: .leading) {
                            Button("\(text)") {
                                countdownTimer.toggleShow()
                            }
//                            .zIndex(1)
                            CountdownTimerView(viewModel: countdownTimer)
//                            .zIndex(2)
                        }
                    } else {
                        Text("\(text)")
//                        .zIndex(1)
                    }
                }
//            }
        }.toggleStyle(CheckboxToggleStyle())
    }
}

struct SessionRecipeStepView_Previews: PreviewProvider {
    // swiftlint:disable force_try line_length
    static let step = try! RecipeStep(content: "Cook for 4 mins")
    static var previews: some View {
        SessionRecipeStepView(viewModel: SessionRecipeStepViewModel(sessionRecipeStep: SessionRecipeStep(step: step, actionTimeTracker: ActionTimeTracker())))
    }
}
