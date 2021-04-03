import Combine
import Foundation

final class UserSettings: ObservableObject {
    @Published var viewType = ViewType.list
    @Published var userId = UserDefaults.standard.string(forKey: "userId")
}

extension UserSettings {
    enum ViewType {
        case list, grid
    }
}
