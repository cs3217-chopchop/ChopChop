import SwiftUI

struct RecipeStepTimersView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: RecipeStepTimersViewModel

    var body: some View {
        Form {
            Section {
                ForEach(viewModel.timers, id: \.self) { timerRowViewModel in
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

                Button("Add timer") {
                    viewModel.timers.append(RecipeStepTimerRowViewModel())
                }

                parseButton
            }

            Section {
                Button("Save timers") {
                    if viewModel.saveTimers() {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .navigationTitle("Timers")
        .alert(isPresented: $viewModel.alertIsPresented) {
            Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage))
        }
    }

    var parseButton: some View {
        Button("Parse timers") {
            viewModel.actionSheetIsPresented = true
        }
        .actionSheet(isPresented: $viewModel.actionSheetIsPresented) {
            ActionSheet(title: Text("Parse step timers"),
                        message: Text("Step: \(viewModel.node.label.content)"),
                        buttons: [
                            .cancel(),
                            .destructive(Text("Overwrite current timers")) {
                                viewModel.parseTimers(shouldOverride: true)
                            },
                            .default(Text("Append to current timers")) {
                                viewModel.parseTimers(shouldOverride: false)
                            }
                        ])
        }
    }
}

struct RecipeStepTimersView_Previews: PreviewProvider {
    static var previews: some View {
        if let step = try? RecipeStep("#") {
            RecipeStepTimersView(viewModel: RecipeStepTimersViewModel(node: RecipeStepNode(step), timers: []))
        }
    }
}
