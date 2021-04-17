import SwiftUI
import Combine

/**
 Represents a view model for a view of a collection of followees.
 */
class FolloweeCollectionViewModel: ObservableObject {
    /// The id of the user who's followees are displayed.
    let userId: String
    let settings: UserSettings

    /// The followees of the user.
    @Published private(set) var followees: [User] = []

    /// Search bar field
    @Published var query = ""

    private let storageManager = StorageManager()
    private var cancellables: Set<AnyCancellable> = []

    init(userId: String, settings: UserSettings) {
        self.userId = userId
        self.settings = settings

        followeesPublisher
            .sink { [weak self] followees in
                self?.followees = followees
            }
            .store(in: &cancellables)
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
