import Combine
import Foundation

final class UserSettings: ObservableObject {
    @Published var viewType = ViewType.list
    @Published var userId: String? {
        didSet {
            setPublisher()
        }
    }

    private let storageManager = StorageManager()
    @Published var user: User?

    init() {
        userId = UserDefaults.standard.string(forKey: "userId")
        setPublisher()
    }

    private func setPublisher() {
        guard let userId = userId else {
            return
        }
        // listener should only be created once
        storageManager.listenUserById(userId: userId) { user in
            self.user = user
        }
    }

}

extension UserSettings {
    enum ViewType {
        case list, grid
    }
}
