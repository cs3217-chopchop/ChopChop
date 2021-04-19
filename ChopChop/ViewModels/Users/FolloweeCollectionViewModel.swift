import SwiftUI
import Combine

/**
 Represents a view model for a view of a collection of followees.
 */
class FolloweeCollectionViewModel: ObservableObject {
    /// The id of the user who's followees are displayed.
    let userId: String

    /// The followees of the user.
    @Published private(set) var followees: [User] = []
    /// The search query.
    @Published var query = "" {
        didSet {
            updateFollowees()
        }
    }
    /// A flag representing whether the data is still being loaded from storage.
    @Published var isLoading = false

    let settings: UserSettings
    private let storageManager = StorageManager()

    init(userId: String, settings: UserSettings) {
        self.userId = userId
        self.settings = settings
    }

    /**
     Loads the collection of followees.
     */
    func load() {
        isLoading = true
        query = ""
    }

    private func updateFollowees() {
        storageManager.fetchUser(id: userId) { user, _ in
            self.storageManager.fetchUsers(ids: user?.followees ?? []) { users, _ in
                self.followees = users.filter { self.query.isEmpty || $0.name.contains(self.query) }
                self.isLoading = false
            }
        }
    }
}
