import Combine
import Foundation
import UIKit

final class UserCollectionViewModel: ObservableObject {
    private let storageManager = StorageManager()
    @Published private(set) var nonFollowees: [UserInfoRecord] = []
    @Published private(set) var followees: [UserInfoRecord] = []

    private let settings: UserSettings

    init(settings: UserSettings) {
        self.settings = settings
        print("viewmodel created")
    }

    func load() {
        storageManager.fetchAllUserInfos { users, _ in
            self.followees = users.filter { self.isFollowee(user: $0) }
            self.nonFollowees = users.filter { self.isNonFollowee(user: $0) }
        }
    }

    private func isNonFollowee(user: UserInfoRecord) -> Bool {
        !(settings.user?.followees.contains(where: { followee in followee == user.id }) ?? false) &&
            user.id != settings.userId
    }

    private func isFollowee(user: UserInfoRecord) -> Bool {
        (settings.user?.followees.contains(where: { followee in followee == user.id }) ?? false) &&
            user.id != settings.userId
    }

}
