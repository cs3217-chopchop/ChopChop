import Combine
import Foundation
import UIKit

final class UserCollectionViewModel: ObservableObject {
    private let storageManager = StorageManager()
    @Published private(set) var nonFollowees: [User] = []
    @Published private(set) var followees: [User] = []

    private let settings: UserSettings

    init(settings: UserSettings) {
        self.settings = settings
        storageManager.fetchAllUsers(completion: onLoadUsers(users:error:))
    }

    func onLoadUsers(users: [User], error: Error?) {
        followees = users.filter { isFollowee(user: $0) }
        nonFollowees = users.filter { isNonFollowee(user: $0) }
    }

    private func isNonFollowee(user: User) -> Bool {
        !(settings.user?.followees.contains(where: { followee in followee == user.id }) ?? false) &&
            user.id != settings.userId
    }

    private func isFollowee(user: User) -> Bool {
        (settings.user?.followees.contains(where: { followee in followee == user.id }) ?? false) &&
            user.id != settings.userId
    }

}
