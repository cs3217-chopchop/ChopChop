import UIKit

final class NonFolloweeViewModel: ObservableObject, Identifiable {
    @Published var user: User
    private let storageManager = StorageManager()

    init(user: User) {
        self.user = user
    }

    func onAdd() {
        guard let USER_ID = USER_ID, let nonFolloweeId = user.id  else {
            assertionFailure()
            return
        }

        storageManager.addFollowee(userId: USER_ID, followeeId: nonFolloweeId)
    }

}
