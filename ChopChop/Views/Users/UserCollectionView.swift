import SwiftUI

struct UserCollectionView: View {
    @ObservedObject var viewModel: UserCollectionViewModel

    var body: some View {
        Section(header: Text("Current followees").font(.title2)) {
            if viewModel.followeeViewModels.isEmpty {
                NotFoundView(entityName: "Followees")
            } else {
                List(viewModel.followeeViewModels) { followee in
                    FolloweeView(viewModel: followee)
                }
            }
        }
        Section(header: Text("Add followees").font(.title2)) {
            if viewModel.nonFolloweeViewModels.isEmpty {
                NotFoundView(entityName: "Other Users")
            } else {
                List(viewModel.nonFolloweeViewModels) { notCurrentFollowee in
                    NonFolloweeView(viewModel: notCurrentFollowee)
                }
            }
        }
    }
}

struct FolloweeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        UserCollectionView(viewModel: UserCollectionViewModel())
    }
}
