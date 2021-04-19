import SwiftUI

/**
 Represents a view of a collection of timers for an instruction step.
 */
struct RecipeStepTimersView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: RecipeStepTimersViewModel

    var body: some View {
        Form {
            Section {
                ForEach(viewModel.timers, id: \.self) { timerRowViewModel in
                    stepTimer(timerRowViewModel)
                }

                addTimerButton
                parseButton
            }

            Section {
                saveButton
            }
        }
        .navigationTitle("Timers")
        .alert(isPresented: $viewModel.alertIsPresented) {
            Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage))
        }
    }

    private func stepTimer(_ timerRowViewModel: RecipeStepTimerRowViewModel) -> some View {
        HStack {
            RecipeStepTimerRowView(viewModel: timerRowViewModel)
            Spacer()
            Button(action: {
                viewModel.timers.removeAll(where: { $0 === timerRowViewModel })
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }

    private var addTimerButton: some View {
        Button("Add timer") {
            viewModel.timers.append(RecipeStepTimerRowViewModel())
        }
    }

    private var parseButton: some View {
        Button("Parse timers") {
            viewModel.actionSheetIsPresented = true
        }
        .actionSheet(isPresented: $viewModel.actionSheetIsPresented) {
            ActionSheet(
                title: Text("Parse step timers"),
                message: Text("Step: \(viewModel.node.label.content)"),
                buttons: [
                    .cancel(),
                    .destructive(Text("Overwrite current timers")) {
                        viewModel.parseTimers(shouldOverwrite: true)
                    },
                    .default(Text("Append to current timers")) {
                        viewModel.parseTimers(shouldOverwrite: false)
                    }
                ])
        }
    }

    private var saveButton: some View {
        Button("Save timers") {
            if viewModel.saveTimers() {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct RecipeStepTimersView_Previews: PreviewProvider {
    static var previews: some View {
        if let step = try? RecipeStep("Preview") {
            RecipeStepTimersView(viewModel: RecipeStepTimersViewModel(node: RecipeStepNode(step), timers: []))
        }
    }
}
