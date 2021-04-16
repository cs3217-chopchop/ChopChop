import SwiftUI
import Combine

class FolloweeCollectionViewModel: ObservableObject {
    private let storageManager = StorageManager()
    let userId: String
    let settings: UserSettings

    @Published private(set) var followees: [User] = []
    @Published var query = ""

    private var followeesCancellable: AnyCancellable?

    init(userId: String, settings: UserSettings) {
        self.userId = userId
        self.settings = settings

        followeesCancellable = followeesPublisher
            .sink { [weak self] followees in
                self?.followees = followees
            }
    }

    private var followeesPublisher: AnyPublisher<[User], Never> {
        $query.map { [self] query -> AnyPublisher<[User], Error> in
            storageManager.followeesPublisher(userId: userId, query: query)
        }
        .map {
            $0.catch { _ in
                Just<[User]>([])
            }
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }
}
