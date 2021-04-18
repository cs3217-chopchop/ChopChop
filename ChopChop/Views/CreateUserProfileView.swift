import SwiftUI

struct CreateUserProfileView: View {
    @ObservedObject var viewModel: CreateUserProfileViewModel

    var body: some View {
        Text("Welcome to chopchop!")
            .font(.largeTitle)
            .padding()
        TextField("Name", text: $viewModel.name)
            .frame(width: 400, height: 50, alignment: .center)
            .border(Color.primary, width: 1)
            .multilineTextAlignment(.center)
        Text(viewModel.errorMessage)
            .foregroundColor(.red)
        Button(action: {
            viewModel.onClick()
        }) {
            Text("Create Account")
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        CreateUserProfileView(viewModel: CreateUserProfileViewModel(settings: UserSettings()))
    }
}
