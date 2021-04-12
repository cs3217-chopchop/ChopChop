import Combine
import Foundation
import SwiftUI

final class OldUserCollectionViewModel: ObservableObject {
    private let storageManager = StorageManager()
    private var usersCancellable: AnyCancellable?
    @Published private(set) var nonFollowees: [User] = []
    @Published private(set) var followees: [User] = []
    private var currentUser: User?

    private let settings: UserSettings

    init(settings: UserSettings) {
        self.settings = settings

        usersCancellable = usersPublisher()
            .sink { [weak self] users in
                self?.currentUser = users.first { $0.id == settings.userId }
                self?.followees = users.filter { self?.isFollowee(user: $0) ?? false }
                self?.nonFollowees = users.filter { self?.isNonFollowee(user: $0) ?? false } // exclude self
            }
    }

    private func usersPublisher() -> AnyPublisher<[User], Never> {
        storageManager.allUsersPublisher()
            .catch { _ in
                Just<[User]>([])
            }
            .eraseToAnyPublisher()
    }

    private func isNonFollowee(user: User) -> Bool {
        !(currentUser?.followees.contains(where: { followee in followee == user.id }) ?? false) &&
            user.id != settings.userId
    }

    private func isFollowee(user: User) -> Bool {
        (currentUser?.followees.contains(where: { followee in followee == user.id }) ?? false) &&
            user.id != settings.userId
    }

}
