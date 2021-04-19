import SwiftUI

struct CreateUserProfileView: View {
    @ObservedObject var viewModel: CreateUserProfileViewModel

    var body: some View {
        VStack {
            Image("chopchop")
                .resizable()
                .frame(width: 320, height: 320)
            Text("Welcome to ChopChop!")
                .font(.largeTitle)
            Text("Please enter a username")
                .foregroundColor(.secondary)

            Form {
                Section(header: Text("Name"), footer: errorMessage) {
                    TextField("Name", text: $viewModel.name)
                }

                Button(action: viewModel.onClick) {
                    Text("Create Account")
                }
            }
            .frame(width: 400, height: 200)
        }
    }

    @ViewBuilder
    var errorMessage: some View {
        if !viewModel.errorMessage.isEmpty {
            Text(viewModel.errorMessage)
                .foregroundColor(.red)
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        CreateUserProfileView(viewModel: CreateUserProfileViewModel(settings: UserSettings()))
    }
}
