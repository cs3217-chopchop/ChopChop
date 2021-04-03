import UIKit

final class FolloweeViewModel: ObservableObject, Identifiable {
    @Published var user: User
    private let storageManager = StorageManager()

    init(user: User) {
        self.user = user
    }

    func onDelete() {
        guard let USER_ID = USER_ID, let followeeID = user.id else {
            assertionFailure()
            return
        }

        storageManager.removeFollowee(userId: USER_ID, followeeId: followeeID)
    }

}
