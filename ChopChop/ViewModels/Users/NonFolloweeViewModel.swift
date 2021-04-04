import UIKit

final class NonFolloweeViewModel: ObservableObject, Identifiable {
    @Published var user: User
    private let storageManager = StorageManager()

    private let settings: UserSettings

    init(user: User, settings: UserSettings) {
        self.user = user
        self.settings = settings
    }

    func onAdd() {
        guard let USER_ID = settings.userId, let nonFolloweeId = user.id  else {
            assertionFailure()
            return
        }

        storageManager.addFollowee(userId: USER_ID, followeeId: nonFolloweeId)
    }

}
