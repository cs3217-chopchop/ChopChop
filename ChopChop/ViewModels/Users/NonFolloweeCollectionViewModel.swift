import SwiftUI
import Combine

/**
 Represents a view model for a view of a collection of non followees.
 */
class NonFolloweeCollectionViewModel: ObservableObject {

    private let storageManager = StorageManager()
    private let settings: UserSettings
    @Published var isLoading = false

    /// The id of the user who's non followees are displayed.
    private let userId: String

    /// The non followees of the user.
    @Published private(set) var nonFollowees: [User] = []

    @Published var query = "" {
        didSet {
            updateNonFollowees()
        }
    }

    init(userId: String, settings: UserSettings) {
        self.userId = userId
        self.settings = settings
    }

    private func updateNonFollowees() {
        isLoading = true
        storageManager.fetchAllUsers { users, _ in
            guard let followees = users.first { $0.id == self.userId }?.followees else {
                return
            }

            self.nonFollowees = users
                .filter { !followees.contains($0.id) && self.userId != $0.id }
                .filter { self.query.isEmpty || $0.name.contains(self.query) }
            self.isLoading = false
        }
    }

    func load() {
        isLoading = true
        updateNonFollowees()
        query = ""
    }

}
