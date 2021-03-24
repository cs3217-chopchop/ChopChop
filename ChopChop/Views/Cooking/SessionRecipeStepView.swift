import SwiftUI

struct SessionRecipeStepView: View {
    @ObservedObject var viewModel: SessionRecipeStepViewModel

    let columns = [
        GridItem(),
        GridItem()
    ]

    var body: some View {
        Toggle(isOn: $viewModel.isCompleted) {
            viewModel.textWithTimers.reduce(Text(""), {
                $0 + Text("\($1.0)")
                    .foregroundColor(viewModel.isCompleted ? Color.gray : $1.1 == nil ? .black : .blue)
            })
            .strikethrough(viewModel.isCompleted, color: nil)
        }.disabled(viewModel.isDisabled)
        .toggleStyle(CheckboxToggleStyle())
        LazyVGrid(columns: columns, spacing: 24) {
            ForEach(viewModel.textWithTimers.compactMap({ $0.1 })) { timer in
                CountdownTimerView(viewModel: timer)
            }
        }
    }
}

struct SessionRecipeStepView_Previews: PreviewProvider {
    // swiftlint:disable force_try line_length
    static var previews: some View {
        SessionRecipeStepView(viewModel:
                                SessionRecipeStepViewModel(sessionRecipeStep: SessionRecipeStep(step: try! RecipeStep(content: "Cook for 4 mins, super long"), actionTimeTracker: ActionTimeTracker())))
    }
}
