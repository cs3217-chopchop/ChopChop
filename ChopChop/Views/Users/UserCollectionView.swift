import SwiftUI

struct UserCollectionView: View {
    @ObservedObject var viewModel: UserCollectionViewModel
    @EnvironmentObject var settings: UserSettings

    var body: some View {
        VStack {
            Section(header: Text("Current followees").font(.title2)) {
                if viewModel.followees.isEmpty {
                    NotFoundView(entityName: "Followees")
                } else {
                    List(viewModel.followees) { followee in
                        FolloweeView(viewModel: FolloweeViewModel(user: followee, settings: settings, reload: viewModel.load))
                    }
                }
            }
            Section(header: Text("Add followees").font(.title2)) {
                if viewModel.nonFollowees.isEmpty {
                    NotFoundView(entityName: "Other Users")
                } else {
                    List(viewModel.nonFollowees) { notCurrentFollowee in
                        NonFolloweeView(viewModel: NonFolloweeViewModel(user: notCurrentFollowee, settings: settings, reload: viewModel.load))
                    }
                }
            }
        }.onAppear {
            print("view created")
            viewModel.load()
        }
    }
}

struct FolloweeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        UserCollectionView(viewModel: UserCollectionViewModel(settings: UserSettings()))
    }
}
