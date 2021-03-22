import SwiftUI

struct SessionRecipeStepView: View {
    @ObservedObject var viewModel: SessionRecipeStepViewModel

    var body: some View {
        Toggle(isOn: $viewModel.isCompleted) {
            viewModel.textWithTimers.reduce(Text(""), {
                $0 + Text("\($1.0)")
                    .foregroundColor(viewModel.isCompleted ? Color.gray : $1.1 == nil ? .black : .blue)
            })
            .strikethrough(viewModel.isCompleted, color: nil)
        }
        .toggleStyle(CheckboxToggleStyle())
        HStack {
            ForEach(viewModel.textWithTimers, id: \.0) { _, timer in
                if let countdownTimer = timer {
                    CountdownTimerView(viewModel: countdownTimer)
                }
            }
        }
    }
}

struct SessionRecipeStepView_Previews: PreviewProvider {
    // swiftlint:disable force_try line_length
    static let step = try! RecipeStep(content: "Cook for 4 mins and type a super longggggggggggggggggggggggggggggggggggggggggggggggggggggggg")
    static var previews: some View {
        SessionRecipeStepView(viewModel: SessionRecipeStepViewModel(sessionRecipeStep: SessionRecipeStep(step: step, actionTimeTracker: ActionTimeTracker())))
    }
}
