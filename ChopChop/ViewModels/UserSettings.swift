import Combine
import Foundation

final class UserSettings: ObservableObject {
    @Published var viewType = ViewType.list
    @Published var userId = UserDefaults.standard.string(forKey: "userId") {
        didSet {
            guard let userId = userId else {
                return
            }
            // listener should only be created once
            storageManager.listenUserById(userId: userId, onChange: { user in self.user = user })
        }
    }

    private let storageManager = StorageManager()
    @Published var user: User?

}

extension UserSettings {
    enum ViewType {
        case list, grid
    }
}
