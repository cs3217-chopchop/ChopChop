import SwiftUI

struct CreateUserProfileView: View {
    @ObservedObject var viewModel: CreateUserProfileViewModel

    var body: some View {
        TextField(viewModel.name, text: $viewModel.name)
//            .foregroundColor(viewModel.errorMsg.isEmpty ? .primary : .red)
//            .frame(width: 100, height: 50, alignment: .center)
//            .border(Color.primary, width: 1)
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
        CreateUserProfileView(viewModel: CreateUserProfileViewModel())
    }
}
