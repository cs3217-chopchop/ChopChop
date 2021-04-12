import SwiftUI
import Combine

final class ProfileViewModel: ObservableObject {
    private let storageManager = StorageManager()
    private let userId: String
    private let settings: UserSettings
    @ObservedObject private(set) var recipesViewModel: OnlineRecipeCollectionViewModel

    private var ownUserCancellable: AnyCancellable?
    private var userCancellable: AnyCancellable?
    private var recipesCancellable: AnyCancellable?

    private var followeeIds: [String] = []
    @Published private(set) var userName = ""
    @Published private(set) var publishedRecipesCount = 0
    @Published private(set) var followeeCount = 0

    init(userId: String, settings: UserSettings) {
        self.userId = userId
        self.settings = settings
        self.recipesViewModel = OnlineRecipeCollectionViewModel(
            publisher: ProfileViewModel.getRecipesPublisher(userId: userId))

        ownUserCancellable = ownUserPublisher?
            .sink { [weak self] ownUser in
                self?.followeeIds = ownUser.followees
            }

        userCancellable = userPublisher
            .sink { [weak self ] user in
                self?.userName = user.name
                self?.followeeCount = user.followees.count
            }

        recipesCancellable = recipesViewModel.$recipes
            .sink { [weak self] recipes in
                self?.publishedRecipesCount = recipes.count
            }
    }

    var isOwnProfile: Bool {
        userId == settings.userId
    }

    var isFollowedByUser: Bool {
        followeeIds.contains(userId)
    }

    func addFollowee() {
        guard let ownId = settings.userId, !isOwnProfile, !isFollowedByUser else {
            return
        }

        storageManager.addFollowee(userId: ownId, followeeId: userId)
        self.objectWillChange.send()
    }

    func removeFollowee() {
        guard let ownId = settings.userId, !isOwnProfile, isFollowedByUser else {
            return
        }

        storageManager.removeFollowee(userId: ownId, followeeId: userId)
        self.objectWillChange.send()
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
