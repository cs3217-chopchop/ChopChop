import SwiftUI
import Combine

final class ProfileViewModel: ObservableObject {
    private let storageManager = StorageManager()
    private let userId: String
    @ObservedObject private(set) var recipesViewModel: OnlineRecipeCollectionViewModel

    private var userCancellable: AnyCancellable?
    private var recipesCancellable: AnyCancellable?

    @Published private(set) var userName = ""
    @Published private(set) var publishedRecipesCount = 0
    @Published private(set) var followeeCount = 0

    init(userId: String) {
        self.userId = userId
        self.recipesViewModel = OnlineRecipeCollectionViewModel(publisher: ProfileViewModel.getRecipesPublisher(userId: userId))

        userCancellable = userPublisher()
            .sink { [weak self ] user in
                self?.userName = user.name
                self?.followeeCount = user.followees.count
            }

        recipesCancellable = recipesViewModel.$recipes
            .sink { [weak self] recipes in
                self?.publishedRecipesCount = recipes.count
            }
    }

    private func userPublisher() -> AnyPublisher<User, Never> {
        storageManager.userByIdPublisher(userId: userId)
            .assertNoFailure()
            .eraseToAnyPublisher()
    }

    private static func getRecipesPublisher(userId: String) -> AnyPublisher<[OnlineRecipe], Error> {
        StorageManager().allRecipesByUsersPublisher(userIds: [userId])
    }
}
