import Combine
import Foundation
import UIKit

final class UserCollectionViewModel: ObservableObject {
    private let storageManager = StorageManager()
    private var usersCancellable: AnyCancellable?
    private var followeesCancellable: AnyCancellable?
    @Published private(set) var users: [User] = []
    @Published private(set) var followees: [User] = []

    private let settings: UserSettings

    init(settings: UserSettings) {
        self.settings = settings

        usersCancellable = usersPublisher()
            .sink { [weak self] users in
                self?.users = users.filter { $0.id != settings.userId } // exclude self
            }

        followeesCancellable = followeesPublisher()
            .sink { [weak self] followees in
                self?.followees = followees
            }
    }

    var nonFollowees: [User] {
        users.filter { user in !followees.contains(where: { followee in followee.id == user.id }) }
    }

    private func usersPublisher() -> AnyPublisher<[User], Never> {
        storageManager.allUsersPublisher()
            .catch { _ in
                Just<[User]>([])
            }
            .eraseToAnyPublisher()
    }

    private func followeesPublisher() -> AnyPublisher<[User], Never> {
        guard let USER_ID = settings.userId else {
            assertionFailure()
            return usersPublisher()
        }

        return storageManager.allFolloweesPublisher(userId: USER_ID)
            .catch { _ in
                Just<[User]>([])
            }
            .eraseToAnyPublisher()
    }

}
