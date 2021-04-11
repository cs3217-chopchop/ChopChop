import Combine
import Foundation
import UIKit

final class UserCollectionViewModel: ObservableObject {
    private let storageManager = StorageManager()
    @Published private(set) var nonFollowees: [UserInfo] = []
    @Published private(set) var followees: [UserInfo] = []

    private let settings: UserSettings

    init(settings: UserSettings) {
        self.settings = settings
    }

    func load() {
        storageManager.fetchAllUsers { users, _ in
            self.followees = users.filter { self.isFollowee(user: $0) }
            self.nonFollowees = users.filter { self.isNonFollowee(user: $0) }
        }
    }

    private func isNonFollowee(user: UserInfo) -> Bool {
        !(settings.user?.followees.contains(where: { followee in followee == user.id }) ?? false) &&
            user.id != settings.userId
    }

    private func isFollowee(user: UserInfo) -> Bool {
        (settings.user?.followees.contains(where: { followee in followee == user.id }) ?? false) &&
            user.id != settings.userId
    }

}
