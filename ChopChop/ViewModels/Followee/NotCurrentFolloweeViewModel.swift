import UIKit

final class NotCurrentFolloweeViewModel: ObservableObject, Identifiable {
    @Published var user: User

    init(user: User) {
        self.user = user
    }

    func onAdd() {
        // only needa update firebase

    }

}
