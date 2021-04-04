import UIKit

final class FolloweeViewModel: ObservableObject, Identifiable {
    @Published var user: User
    private let storageManager = StorageManager()

    private let settings: UserSettings

    init(user: User, settings: UserSettings) {
        self.user = user
        self.settings = settings
    }

    func onDelete() {
        guard let USER_ID = settings.userId, let followeeID = user.id else {
            assertionFailure()
            return
        }

        storageManager.removeFollowee(userId: USER_ID, followeeId: followeeID)
    }

}
