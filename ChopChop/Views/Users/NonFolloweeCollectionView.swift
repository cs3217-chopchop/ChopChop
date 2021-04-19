import SwiftUI

/**
 Represents a view of a collection of non followees.
 */
struct NonFolloweeCollectionView: View {
    @StateObject var viewModel: NonFolloweeCollectionViewModel
    @EnvironmentObject var settings: UserSettings

    var body: some View {
        ZStack {
            VStack {
                SearchBar(text: $viewModel.query, placeholder: "Search...")

                if viewModel.nonFollowees.isEmpty {
                    NotFoundView(entityName: "Non Followees")
                } else {
                    nonFolloweeList
                }
            }

            ProgressView(isShow: $viewModel.isLoading)
        }
        .navigationTitle(Text("Add Followees"))
        .onAppear {
            viewModel.load()
        }
    }

    private var nonFolloweeList: some View {
        List {
            ForEach(viewModel.nonFollowees) { nonFollowee in
                AddFolloweeRow(followee: nonFollowee)
            }
        }
    }

    @ViewBuilder
    private func AddFolloweeRow(followee: User) -> some View {
        NavigationLink(
            destination: ProfileView(viewModel: ProfileViewModel(userId: followee.id, settings: settings))
        ) {
            HStack {
                Image("user")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())

                Text(followee.name)

                Spacer()
            }
        }
        .padding([.top, .bottom], 6)
    }
}
