import SwiftUI
import Combine

/**
 Represents a view model for a view of a collection of followees.
 */
class FolloweeCollectionViewModel: ObservableObject {
    private let storageManager = StorageManager()

    /// The id of the user who's followees are displayed.
    let userId: String

    let settings: UserSettings
    @Published var isLoading = false

    /// The followees of the user.
    @Published private(set) var followees: [User] = []

    @Published var query = "" {
        didSet {
            updateFollowees()
        }
    }

    init(userId: String, settings: UserSettings) {
        self.userId = userId
        self.settings = settings
    }

    private func updateFollowees() {
        storageManager.fetchUser(id: userId) { user, _ in
            self.storageManager.fetchUsers(ids: user?.followees ?? []) { users, _ in
                self.followees = users.filter { self.query.isEmpty || $0.name.contains(self.query) }
                self.isLoading = false
            }
        }
    }

    func load() {
        isLoading = true
        query = ""
    }

}
