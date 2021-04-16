import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @ObservedObject var recipesViewModel: OnlineRecipeCollectionViewModel

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        self.recipesViewModel = viewModel.recipesViewModel
    }

    var body: some View {
        OnlineRecipeCollectionView(viewModel: recipesViewModel) {
            VStack {
                profileHeader

                Divider()
                    .padding()

                if !viewModel.isOwnProfile {
                    followUnfollowButton

                    Divider()
                        .padding()
                }
            }
        }
    }

    @ViewBuilder
    var followUnfollowButton: some View {
        if viewModel.isFollowedByUser {
            Button(action: viewModel.removeFollowee) {
                Label("Unfollow", systemImage: "person.badge.minus")
            }
        } else {
            Button(action: viewModel.addFollowee) {
                Label("Follow", systemImage: "person.badge.plus")
            }
        }
    }

    var profileHeader: some View {
        HStack {
            VStack {
                Image("default-user")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                Text(viewModel.userName)
                    .bold()
            }
            Spacer()
            HStack(spacing: 50) {
                VStack {
                    Text("\(viewModel.publishedRecipesCount)")
                        .font(.title)
                        .bold()
                    Text("Recipes")
                }
                VStack {
                    Text("\(viewModel.followeeCount)")
                        .font(.title)
                        .bold()
                    Text("Followees")
                }
            }
        }
        .padding([.leading, .trailing], 50)
    }
}
