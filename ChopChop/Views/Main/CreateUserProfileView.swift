import SwiftUI

/**
 Represents a view of the initial user profile creation.
 */
struct CreateUserProfileView: View {
    @StateObject var viewModel: CreateUserProfileViewModel

    var body: some View {
        VStack {
            appImage
            Text("Welcome to ChopChop!")
                .font(.largeTitle)
            Text("Please enter a username")
                .foregroundColor(.secondary)

            userProfileForm
        }
    }

    private var appImage: some View {
        Image("chopchop")
            .resizable()
            .frame(width: 320, height: 320)
    }

    private var userProfileForm: some View {
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

    @ViewBuilder
    private var errorMessage: some View {
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
