import Combine
import Foundation

/**
 Tracks the details and settings of the current user.
 */
final class UserSettings: ObservableObject {
    @Published var viewType = ViewType.list
    /// The id of the current user.
    @Published var userId: String? {
        didSet {
            UserDefaults.standard.set(userId, forKey: "userId")
            setPublisher()
        }
    }
    /// The current user, or `nil` if the user has not completed the initial profile creation.
    private(set) var user: User?

    private let storageManager = StorageManager()

    init() {
        userId = UserDefaults.standard.string(forKey: "userId")
        setPublisher()
    }

    private func setPublisher() {
        guard let userId = userId else {
            return
        }
        // listener should only be created once
        storageManager.userListener(id: userId) { user in
            self.user = user
        }
    }
}

extension UserSettings {
    enum ViewType {
        case list, grid
    }
}
