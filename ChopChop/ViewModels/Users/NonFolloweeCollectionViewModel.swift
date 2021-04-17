import SwiftUI
import Combine

class NonFolloweeCollectionViewModel: ObservableObject {
    private let storageManager = StorageManager()
    private let settings: UserSettings
    @Published var isLoading = false

    @Published private(set) var nonFollowees: [User] = []
    @Published var query = "" {
        didSet {
            updateNonFollowees()
        }
    }

    init(settings: UserSettings) {
        self.settings = settings
    }

    private func updateNonFollowees() {
        isLoading = true
        storageManager.fetchAllUsers { users, _ in
            guard let followees = self.settings.user?.followees else {
                return
            }

            self.nonFollowees = users
                .filter { !followees.contains($0.id) && self.settings.userId != $0.id }
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
