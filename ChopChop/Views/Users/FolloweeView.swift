import SwiftUI

struct FolloweeView: View {
    @ObservedObject var viewModel: FolloweeViewModel

    var body: some View {
        HStack {
            Text(viewModel.user.name)
            Spacer()
            Button(action: {
                viewModel.onDelete()
            }) {
                Image(systemName: "trash")
            }
        }
    }
}

struct CurrentFolloweeView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable force_try
        FolloweeView(viewModel: FolloweeViewModel(user: try! User(id: "Bob", name: "Bob")))
    }
}
