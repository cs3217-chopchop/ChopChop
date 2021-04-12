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
}

struct RecipeStepTimersView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeStepTimersView(viewModel: RecipeStepTimersViewModel(timers: []))
    }
}
