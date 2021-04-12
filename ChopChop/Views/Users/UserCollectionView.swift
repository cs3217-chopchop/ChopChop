import SwiftUI

struct UserCollectionView: View {
    @ObservedObject var viewModel: OldUserCollectionViewModel
    @EnvironmentObject var settings: UserSettings

    var body: some View {
        Section(header: Text("Current followees").font(.title2)) {
            if viewModel.followees.isEmpty {
                NotFoundView(entityName: "Followees")
            } else {
                List(viewModel.followees) { followee in
                    FolloweeView(viewModel: FolloweeViewModel(user: followee, settings: settings))
                }
            }
        }
        Section(header: Text("Add followees").font(.title2)) {
            if viewModel.nonFollowees.isEmpty {
                NotFoundView(entityName: "Other Users")
            } else {
                List(viewModel.nonFollowees) { notCurrentFollowee in
                    NonFolloweeView(viewModel: NonFolloweeViewModel(user: notCurrentFollowee, settings: settings))
                }
            }
        }
    }
}

struct FolloweeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        UserCollectionView(viewModel: OldUserCollectionViewModel(settings: UserSettings()))
    }
}
