import Combine
import Foundation
import UIKit

final class UserCollectionViewModel: ObservableObject {
    @Published private(set) var followeeViewModels: [FolloweeViewModel] = []
    @Published private(set) var nonFolloweeViewModels: [NonFolloweeViewModel] = []

    private let storageManager = StorageManager()
    private var usersCancellable: AnyCancellable?
    private var followeesCancellable: AnyCancellable?
    private var users: [User] = []
    private var followees: [User] = []

    init() {
        usersCancellable = usersPublisher()
            .sink { [weak self] users in
                self?.users = users.filter { $0.id != USER_ID } // exclude self
                self?.updateViewModels()
            }

        followeesCancellable = followeesPublisher()
            .sink { [weak self] followees in
                self?.followees = followees
                self?.updateViewModels()
            }
    }

    private func updateViewModels() {
        self.followeeViewModels = []
        self.nonFolloweeViewModels = []
        for user in users {
            if (followees.contains { $0.id == user.id }) {
                followeeViewModels.append(FolloweeViewModel(user: user))
            } else {
                nonFolloweeViewModels.append(NonFolloweeViewModel(user: user))
            }
        }
    }

    private func usersPublisher() -> AnyPublisher<[User], Never> {
        storageManager.allUsersPublisher()
            .catch { _ in
                Just<[User]>([])
            }
            .eraseToAnyPublisher()
    }

    private func followeesPublisher() -> AnyPublisher<[User], Never> {
        guard let USER_ID = USER_ID else {
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
