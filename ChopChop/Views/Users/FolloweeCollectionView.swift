import SwiftUI

/**
 Represents a view of a collection of followees.
 */
struct FolloweeCollectionView: View {
    @ObservedObject var viewModel: FolloweeCollectionViewModel

    var body: some View {
        VStack {
            SearchBar(text: $viewModel.query, placeholder: "Search followees...")
            toolbar

            Divider()
                .padding(EdgeInsets(top: 1, leading: 16, bottom: 0, trailing: 16))

            if viewModel.followees.isEmpty {
                NotFoundView(entityName: "Followees")
            } else {
                followeeList
            }

            ProgressView(isShow: $viewModel.isLoading)
        }
        .navigationTitle(Text("Followees"))
        .onAppear {
            viewModel.load()
        }
    }

    private var toolbar: some View {
        HStack {
            addFolloweeButton
            Spacer()
        }
        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
    }

    private var addFolloweeButton: some View {
        NavigationLink(
            destination: NonFolloweeCollectionView(
                viewModel: NonFolloweeCollectionViewModel(
                    userId: viewModel.userId,
                    settings: viewModel.settings))) {
            Image(systemName: "plus")
        }
    }

    private var followeeList: some View {
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
                Image("user")
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
