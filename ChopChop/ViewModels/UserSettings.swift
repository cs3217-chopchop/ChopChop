import Combine

final class UserSettings: ObservableObject {
    @Published var viewType = ViewType.list
}

extension UserSettings {
    enum ViewType {
        case list, grid
    }
}
