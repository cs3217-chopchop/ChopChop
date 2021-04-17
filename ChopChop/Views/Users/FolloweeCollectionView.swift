import SwiftUI

struct FolloweeCollectionView: View {
    @ObservedObject var viewModel: FolloweeCollectionViewModel

    var body: some View {
        VStack {
            SearchBar(text: $viewModel.query, placeholder: "Search followees...")
            HStack {
                NavigationLink(
                    destination: AddFolloweeView(
                        viewModel: NonFolloweeCollectionViewModel(
                            settings: viewModel.settings))) {
                    Image(systemName: "plus")
                }
                Spacer()
            }
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

            Divider()
                .padding(EdgeInsets(top: 1, leading: 16, bottom: 0, trailing: 16))

            if viewModel.followees.isEmpty {
                NotFoundView(entityName: "Followees")
            } else {
                followeeList
            }
        }
        .navigationTitle(Text("Followees"))
        .onAppear {
            viewModel.load()
        }
    }

    var followeeList: some View {
        List {
            ForEach(viewModel.followees) { followee in
                FolloweeRow(followee: followee)
            }
        }
    }

    @ViewBuilder
    func FolloweeRow(followee: User) -> some View {
        NavigationLink(
            destination: ProfileView(viewModel: ProfileViewModel(userId: followee.id, settings: viewModel.settings))
        ) {
            HStack {
                Image("default-user")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())

                Text(followee.name)
            }
            .padding([.top, .bottom], 6)
        }
    }
}
