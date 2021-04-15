import UIKit

final class NonFolloweeViewModel: ObservableObject, Identifiable {
    @Published var user: UserInfoRecord
    private let storageManager = StorageManager()

    private let settings: UserSettings
    let reload: () -> Void // to reload CollectionViewModel

    init(user: UserInfoRecord, settings: UserSettings, reload: @escaping () -> Void) {
        self.user = user
        self.settings = settings
        self.reload = reload
    }

    func onAdd() {
        guard let userId = settings.userId, let nonFolloweeId = user.id else {
            assertionFailure()
            return
        }

        storageManager.addFollowee(userId: userId, followeeId: nonFolloweeId, completion: reload)
        reload()
    }

}
