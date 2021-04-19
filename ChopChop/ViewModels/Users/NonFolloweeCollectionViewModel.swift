import SwiftUI
import Combine

/**
 Represents a view model for a view of a collection of non followees.
 */
class NonFolloweeCollectionViewModel: ObservableObject {
    /// The id of the user who's non followees are displayed.
    private let userId: String

    /// The non followees of the user.
    @Published private(set) var nonFollowees: [User] = []
    /// The search query.
    @Published var query = "" {
        didSet {
            updateNonFollowees()
        }
    }
    /// A flag representing whether the data is still being loaded from storage.
    @Published var isLoading = false

    private let settings: UserSettings
    private let storageManager = StorageManager()

    init(userId: String, settings: UserSettings) {
        self.userId = userId
        self.settings = settings
    }

    /**
     Loads the collection of non followees.
     */
    func load() {
        isLoading = true
        updateNonFollowees()
        query = ""
    }

    private func updateNonFollowees() {
        isLoading = true
        storageManager.fetchAllUsers { users, _ in
            guard let followees = users.first(where: { $0.id == self.userId })?.followees else {
                return
            }

            self.nonFollowees = users
                .filter { !followees.contains($0.id) && self.userId != $0.id }
                .filter { self.query.isEmpty || $0.name.contains(self.query) }
            self.isLoading = false
        }
    }
}
