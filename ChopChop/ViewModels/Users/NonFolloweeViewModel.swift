import UIKit

final class NonFolloweeViewModel: ObservableObject, Identifiable {
    @Published var user: UserInfo
    private let storageManager = StorageManager()

    private let settings: UserSettings

    init(user: UserInfo, settings: UserSettings) {
        self.user = user
        self.settings = settings
    }

    func onAdd() {
        guard let userId = settings.userId, let nonFolloweeId = user.id  else {
            assertionFailure()
            return
        }

        storageManager.addFollowee(userId: userId, followeeId: nonFolloweeId)
    }

}
