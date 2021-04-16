import SwiftUI
import Combine

class FolloweeCollectionViewModel: ObservableObject {
    private let storageManager = StorageManager()
    let settings: UserSettings

    @Published private(set) var followees: [User] = []
    @Published var query = "" {
        didSet {
            updateFollowees()
        }
    }

    init(settings: UserSettings) {
        self.settings = settings
        updateFollowees()
    }

    private func updateFollowees() {
        storageManager.fetchUsers(ids: settings.user?.followees ?? []) { users, _ in
            self.followees = users.filter { $0.name.contains(self.query) }
        }
    }

}
