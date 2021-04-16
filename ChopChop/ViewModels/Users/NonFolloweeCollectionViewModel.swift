import SwiftUI
import Combine

class NonFolloweeCollectionViewModel: ObservableObject {
    private let storageManager = StorageManager()
    private let settings: UserSettings

    @Published private(set) var nonFollowees: [User] = []
    @Published var query = "" {
        didSet {
            updateNonFollowees()
        }
    }

    init(settings: UserSettings) {
        self.settings = settings
        updateNonFollowees()
    }

    private func updateNonFollowees() {
        storageManager.fetchAllUsers { users, _ in
            guard let followees = self.settings.user?.followees else {
                return
            }
            self.nonFollowees = users
                .filter { !followees.contains($0.id) && self.settings.userId != $0.id }
                .filter { $0.name.contains(self.query) }
        }
    }

}
