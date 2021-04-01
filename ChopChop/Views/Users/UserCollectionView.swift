import SwiftUI

struct UserCollectionView: View {
    @ObservedObject var viewModel: UserCollectionViewModel

    var body: some View {
        Text("Current followees")
        ForEach(viewModel.followeeViewModels) { followee in
            FolloweeView(viewModel: followee)
        }
        Text("Add followees")
        ForEach(viewModel.nonFolloweeViewModels) { notCurrentFollowee in
            NonFolloweeView(viewModel: notCurrentFollowee)
        }
    }
}

struct FolloweeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        UserCollectionView(viewModel: UserCollectionViewModel())
    }
}
