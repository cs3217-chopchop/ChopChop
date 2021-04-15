import UIKit

final class FolloweeViewModel: ObservableObject, Identifiable {
    @Published var user: UserInfoRecord
    private let storageManager = StorageManager()

    private let settings: UserSettings
    private let reload: () -> Void

    init(user: UserInfoRecord, settings: UserSettings, reload: @escaping () -> Void) {
        self.user = user
        self.settings = settings
        self.reload = reload
    }

    func onDelete() {
        guard let userId = settings.userId, let followeeID = user.id else {
            assertionFailure()
            return
        }

        storageManager.removeFollowee(userId: userId, followeeId: followeeID, completion: reload)
    }

}
