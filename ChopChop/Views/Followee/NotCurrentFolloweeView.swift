import SwiftUI

struct NotCurrentFolloweeView: View {
    @ObservedObject var viewModel: NotCurrentFolloweeViewModel

    var body: some View {
        HStack {
            Text(viewModel.user.name)
            Button(action: {
                viewModel.onAdd()
            }) {
                Text("Submit") // TODO deleteicon
            }
        }
    }
}

struct NotCurrentFolloweeView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable force_try
        NotCurrentFolloweeView(viewModel: NotCurrentFolloweeViewModel(user: try! User(id: "Bob", name: "Bob")))
    }
}
