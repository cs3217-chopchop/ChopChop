import SwiftUI
import Combine

/**
 Represents a view model for a view of a user profile.
 */
final class ProfileViewModel: ObservableObject {
    /// The id of the user displayed in the profile view.
    private let userId: String
    /// The view model containing the recipes published by the displayed user.
    @ObservedObject private(set) var recipesViewModel: OnlineRecipeCollectionViewModel

    /// User profile details
    @Published private(set) var userName = ""
    @Published private(set) var publishedRecipesCount = 0
    @Published private(set) var followeeCount = 0
    @Published private(set) var isFollowedByUser = false

    /// A flag representing whether the data is still being loaded from storage.
    @Published var isLoading = false

    private let settings: UserSettings
    private let storageManager = StorageManager()
    private var cancellables: Set<AnyCancellable> = []

    init(userId: String, settings: UserSettings) {
        self.userId = userId
        self.settings = settings
        self.recipesViewModel = OnlineRecipeCollectionViewModel(userIds: [userId], settings: settings)

        recipesViewModel.$recipes
            .sink { [weak self] recipes in
                self?.publishedRecipesCount = recipes.count
            }
            .store(in: &cancellables)
    }

    /// Checks if the profile belongs to the current user.
    var isOwnProfile: Bool {
        userId == settings.userId
    }

    /**
     Adds the user as a followee of the current user.
     If the current user is already following the user or if the profile belongs to the current user, do nothing.
     */
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

    /**
     Removes the user as a followee of the current user.
     If the current user is not following the user or if the profile belongs to the current user, do nothing.
     */
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

    /**
     Loads the profile of the user.
     */
    func load() {
        isLoading = true
        guard !isOwnProfile else {
            followeeCount = settings.user?.followees.count ?? 0
            userName = settings.user?.name ?? ""
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
