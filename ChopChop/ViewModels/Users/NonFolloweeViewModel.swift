import UIKit

final class NonFolloweeViewModel: ObservableObject, Identifiable {
    @Published var user: User
    private let storageManager = StorageManager()

    init(user: User) {
        self.user = user
    }

    func onAdd() {
        storageManager.addFollowee(userId: USER_ID, followeeId: user.id)
    }

}
