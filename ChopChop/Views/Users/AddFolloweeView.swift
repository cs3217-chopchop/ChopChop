import SwiftUI

struct AddFolloweeView: View {
    @ObservedObject var viewModel: NonFolloweeCollectionViewModel

    var body: some View {
        VStack {
            SearchBar(text: $viewModel.query, placeholder: "Search...")

            if viewModel.nonFollowees.isEmpty {
                NotFoundView(entityName: "Non Followees")
            } else {
                nonFolloweeList
            }
        }
        .navigationTitle(Text("Add Followees"))
        .onAppear {
            viewModel.query = ""
        }
    }

    var nonFolloweeList: some View {
        List {
            ForEach(viewModel.nonFollowees) { nonFollowee in
                AddFolloweeRow(followee: nonFollowee)
            }
        }
    }

    @ViewBuilder
    func AddFolloweeRow(followee: User) -> some View {
        if let id = followee.id {
            NavigationLink(
                destination: ProfileView(viewModel: ProfileViewModel(userId: id, settings: viewModel.settings))
            ) {
                HStack {
                    Image("default-user")
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
}
