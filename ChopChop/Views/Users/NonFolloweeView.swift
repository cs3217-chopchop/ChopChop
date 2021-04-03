import SwiftUI

struct NonFolloweeView: View {
    @ObservedObject var viewModel: NonFolloweeViewModel

    var body: some View {
        HStack {
            Text(viewModel.user.name)
            Spacer()
            Button(action: {
                viewModel.onAdd()
            }) {
                Image(systemName: "plus")
            }
        }
    }
}

struct NotCurrentFolloweeView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable force_try
        NonFolloweeView(viewModel: NonFolloweeViewModel(user: try! User(id: "Bob", name: "Bob")))
    }
}
