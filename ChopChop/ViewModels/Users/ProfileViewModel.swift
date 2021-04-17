import SwiftUI
import Combine

final class ProfileViewModel: ObservableObject {
    private let storageManager = StorageManager()
    private let userId: String
    private let settings: UserSettings
    @ObservedObject private(set) var recipesViewModel: OnlineRecipeCollectionViewModel
    private var publishedRecipesCountCancellable: Any?

    @Published private(set) var userName = "No name"
    @Published private(set) var publishedRecipesCount = 0
    @Published private(set) var followeeCount = 0
    @Published private(set) var isFollowedByUser = false

    @Published var isLoading = false

    init(userId: String, settings: UserSettings) {
        self.userId = userId
        self.settings = settings
        self.recipesViewModel = OnlineRecipeCollectionViewModel(userIds: [userId], settings: settings)
        publishedRecipesCountCancellable = recipesViewModel.$recipes
            .sink { [weak self] recipes in
                self?.publishedRecipesCount = recipes.count
            }
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
            self.load()
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
            self.load()
        }
    }

    func load() {
        isLoading = true
        guard !isOwnProfile else {
            followeeCount = settings.user?.followees.count ?? 0
            userName = settings.user?.name ?? "No name"
            updateRecipeCount()
            return
        }
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
                self.isLoading = false
                return
            }
            self.userName = user.name
            self.followeeCount = user.followees.count
            self.isLoading = false
        }
    }

    private func updateRecipeCount() {
        storageManager.fetchOnlineRecipes(userIds: [userId]) { onlineRecipes, err in
            guard err == nil else {
                self.isLoading = false
                return
            }
            self.publishedRecipesCount = onlineRecipes.count
            self.isLoading = false
        }
    }

}
