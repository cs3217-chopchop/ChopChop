import UIKit

final class CurrentFolloweeViewModel: ObservableObject, Identifiable {
    @Published var user: User

    init(user: User) {
        self.user = user
    }

    func onDelete() {
        // only needa update firebase

    }

}
