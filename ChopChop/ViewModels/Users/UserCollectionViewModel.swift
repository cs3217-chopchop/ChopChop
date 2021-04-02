import Combine
import Foundation
import UIKit

final class UserCollectionViewModel: ObservableObject {
    @Published private(set) var followeeViewModels: [FolloweeViewModel]
    @Published private(set) var nonFolloweeViewModels: [NonFolloweeViewModel]

    private let storageManager = StorageManager()
    private var usersCancellable: AnyCancellable?
    private var followeesCancellable: AnyCancellable?
    private var users: [User]
    private var followees: [User]

    init() {
        usersCancellable = usersPublisher()
            .sink { [weak self] users in
                self?.users = users
                updateViewModels()
            }

        followeesCancellable = followeesPublisher()
            .sink { [weak self] followees in
                self?.followees = followees
                updateViewModels()
            }
    }

    private func updateViewModels() {
        self?.followeeViewModels = []
        self?.nonFolloweeViewModels = []
        for user in users {
            if (followees.contains { $0 == user }) {
                followeeViewModels.append(FolloweeViewModel(user: user))
            } else {
                nonFolloweeViewModels.append(NonFolloweeViewModel(user: user))
            }
        }
    }

    private func usersPublisher() -> AnyPublisher<[User], Never> {
        storageManager.usersPublisher()
            .catch { _ in
                Just<[User]>([])
            }
            .eraseToAnyPublisher()
    }

    private func followeesPublisher() -> AnyPublisher<[User], Never> {
        storageManager.followeesPublisher()
            .catch { _ in
                Just<[User]>([])
            }
            .eraseToAnyPublisher()
    }

}
