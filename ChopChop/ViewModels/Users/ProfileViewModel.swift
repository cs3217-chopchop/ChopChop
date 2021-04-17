import SwiftUI
import Combine

final class ProfileViewModel: ObservableObject {
    private let storageManager = StorageManager()
    private let userId: String
    private let settings: UserSettings
    @ObservedObject private(set) var recipesViewModel: OnlineRecipeCollectionViewModel

    @Published private(set) var userName = "No name"
    @Published private(set) var publishedRecipesCount = 0
    @Published private(set) var followeeCount = 0

    @Published private(set) var isFollowedByUser = false

    init(userId: String, settings: UserSettings) {
        self.userId = userId
        self.settings = settings
        self.recipesViewModel = OnlineRecipeCollectionViewModel(userIds: [userId], settings: settings)
    }

    var isOwnProfile: Bool {
        userId == settings.userId
    }

    func addFollowee() {
        guard let ownId = settings.userId, !isOwnProfile, !isFollowedByUser else {
            return
        }

        storageManager.addFollowee(userId: ownId, followeeId: userId) { err in
            guard err == nil else {
                return
            }
            self.updateIsFollowedByUser()
            self.followeeCount += 1
        }
    }

    func removeFollowee() {
        guard let ownId = settings.userId, !isOwnProfile, isFollowedByUser else {
            return
        }

        storageManager.removeFollowee(userId: ownId, followeeId: userId) { err in
            guard err == nil else {
                return
            }
            self.updateIsFollowedByUser()
            self.followeeCount -= 1
        }
    }

    func load() {
        updateIsFollowedByUser()
        updateUser()
        updateRecipeCount()
    }

    private func updateIsFollowedByUser() {
        isFollowedByUser = settings.user?.followees.contains(userId) == true
    }

    private func updateUser() {
        storageManager.fetchUser(id: userId) { user, err in
            guard let user = user, err == nil else {
                return
            }
            self.userName = user.name
            self.followeeCount = user.followees.count
        }
    }

    private func updateRecipeCount() {
        storageManager.fetchOnlineRecipes(userIds: [userId]) { onlineRecipes, err in
            guard err == nil else {
                return
            }
            self.publishedRecipesCount = onlineRecipes.count
        }
    }

}
