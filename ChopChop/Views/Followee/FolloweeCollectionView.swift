import SwiftUI

struct FolloweeCollectionView: View {
    @ObservedObject var viewModel: FolloweeCollectionViewModel

    var body: some View {
        Text("Current followees")
        ForEach(viewModel.currentFolloweeViewModels) { followee in
            CurrentFolloweeView(viewModel: followee)
        }
        Text("Add followees")
        ForEach(viewModel.notCurrentFolloweeViewModels) { notCurrentFollowee in
            NotCurrentFolloweeView(viewModel: notCurrentFollowee)
        }
    }
}

struct FolloweeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        FolloweeCollectionView(viewModel: FolloweeCollectionViewModel())
    }
}
