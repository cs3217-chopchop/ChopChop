import UIKit

final class FolloweeViewModel: ObservableObject, Identifiable {
    @Published var user: User
    private let storageManager = StorageManager()

    init(user: User) {
        self.user = user
    }

    func onDelete() {
        storageManager.removeFollowee(userId: USER_ID, followeeId: user.id)
    }

}
