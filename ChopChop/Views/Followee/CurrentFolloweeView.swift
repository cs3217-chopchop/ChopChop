import SwiftUI

struct CurrentFolloweeView: View {
    @ObservedObject var viewModel: CurrentFolloweeViewModel

    var body: some View {
        HStack {
            Text(viewModel.user.name)
            Button(action: {
                viewModel.onDelete()
            }) {
                Text("Submit") // TODO deleteicon
            }
        }
    }
}

struct CurrentFolloweeView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable force_try
        CurrentFolloweeView(viewModel: CurrentFolloweeViewModel(user: try! User(id: "Bob", name: "Bob")))
    }
}
