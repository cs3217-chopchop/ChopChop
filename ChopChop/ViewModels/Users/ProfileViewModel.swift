import SwiftUI
import Combine

/**
 Represents a view model for a view of a user profile.
 */
final class ProfileViewModel: ObservableObject {
    /// The id of the user displayed in the profile view.
    private let userId: String
    /// The ids of the followees of the user.
    private var followeeIds: [String] = []

    /// User profile details
    @Published private(set) var userName = ""
    @Published private(set) var publishedRecipesCount = 0
    @Published private(set) var followeeCount = 0
    @Published private(set) var isFollowedByUser = false

    private let settings: UserSettings
    private let storageManager = StorageManager()
    private var cancellables: Set<AnyCancellable> = []

    @ObservedObject private(set) var recipesViewModel: OnlineRecipeCollectionViewModel

    init(userId: String, settings: UserSettings) {
        self.userId = userId
        self.settings = settings
        self.recipesViewModel = OnlineRecipeCollectionViewModel(
            publisher: ProfileViewModel.getRecipesPublisher(userId: userId))

        ownUserPublisher?
            .sink { [weak self] ownUser in
                self?.followeeIds = ownUser.followees
                self?.isFollowedByUser = ownUser.followees.contains(userId)
            }
            .store(in: &cancellables)

        userPublisher
            .sink { [weak self ] user in
                self?.userName = user.name
                self?.followeeCount = user.followees.count
            }
            .store(in: &cancellables)

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

        storageManager.addFollowee(userId: ownId, followeeId: userId)
    }

    /**
     Removes the user as a followee of the current user.
     If the current user is not following the user or if the profile belongs to the current user, do nothing.
     */
    func removeFollowee() {
        guard let ownId = settings.userId, !isOwnProfile, isFollowedByUser else {
            return
        }

        storageManager.removeFollowee(userId: ownId, followeeId: userId)
    }

    private var ownUserPublisher: AnyPublisher<User, Never>? {
        guard let ownId = settings.userId else {
            return nil
        }

        return storageManager.userByIdPublisher(userId: ownId)
            .assertNoFailure()
            .eraseToAnyPublisher()
    }

    private var userPublisher: AnyPublisher<User, Never> {
        storageManager.userByIdPublisher(userId: userId)
            .assertNoFailure()
            .eraseToAnyPublisher()
    }

    private static func getRecipesPublisher(userId: String) -> AnyPublisher<[OnlineRecipe], Error> {
        StorageManager().allRecipesByUsersPublisher(userIds: [userId])
    }
}
