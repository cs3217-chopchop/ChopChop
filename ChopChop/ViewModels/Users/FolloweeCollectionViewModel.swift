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
    }

    private func updateFollowees() {
        storageManager.fetchUsers(ids: settings.user?.followees ?? []) { users, _ in
            self.followees = users.filter { self.query.isEmpty || $0.name.contains(self.query) }
        }
    }

    func load() {
        updateFollowees()
        query = ""
    }

}
