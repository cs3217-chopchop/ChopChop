import SwiftUI
import Combine

class NonFolloweeCollectionViewModel: ObservableObject {
    private let storageManager = StorageManager()
    private let userId: String
    let settings: UserSettings

    @Published private(set) var nonFollowees: [User] = []
    @Published var query = ""

    private var userCancellable: AnyCancellable?
    private var nonFolloweesCancellable: AnyCancellable?

    init(userId: String, settings: UserSettings) {
        self.userId = userId
        self.settings = settings

        userCancellable = userPublisher
            .sink { [weak self] user in
                self?.nonFolloweesCancellable = self?.nonFolloweesPublisher(followeeIds: user.followees)
                    .sink { [weak self] nonFollowees in
                        self?.nonFollowees = nonFollowees
                    }
            }
    }

    private var userPublisher: AnyPublisher<User, Never> {
        storageManager.userByIdPublisher(userId: userId)
            .assertNoFailure()
            .eraseToAnyPublisher()
    }

    private func nonFolloweesPublisher(followeeIds: [String]) -> AnyPublisher<[User], Never> {
        $query.map { [self] query -> AnyPublisher<[User], Error> in
            storageManager.allUsersPublisher(query: query)
        }
        .map {
            $0.catch { _ in
                Just<[User]>([])
            }
        }
        .map {
            $0.map {
                $0.filter { user in
                    guard let id = user.id else {
                        return false
                    }

                    return !followeeIds.contains(id) && self.userId != id
                }
            }
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }
}
