import Combine
import Foundation

final class OnlineRecipeCollectionViewModel: ObservableObject {
//    @Published var query = ""
    @Published private(set) var recipes: [OnlineRecipe] = []
    @Published private var followeeIds: [String] = []
    @Published private var userIds: [String] = []
//    @Published private(set) var recipeIngredients: Set<String> = []
//    @Published var selectedIngredients: Set<String> = []
//
//    @Published var alertIsPresented = false
//    @Published var alertTitle = ""
//    @Published var alertMessage = ""

    @Published var filter = OnlineRecipeFilter.everyone

    private let storageManager = StorageManager()
    private var recipesCancellable: AnyCancellable?
    private var followeesCancellable: AnyCancellable?
    private var usersCancellable: AnyCancellable?

    init() {
        recipesCancellable = recipesPublisher()
            .sink { [weak self] recipes in
                self?.recipes = recipes
            }

        followeesCancellable = followeesPublisher()
            .sink { [weak self] followees in
                self?.followeeIds = followees.compactMap { $0.id }
            }

        usersCancellable = allUsersPublisher()
            .sink { [weak self] users in
                self?.userIds = users.compactMap { $0.id }
            }
    }

    private func followeesPublisher() -> AnyPublisher<[User], Never> {
        storageManager.allFolloweesPublisher(userId: USER_ID)
            .catch { _ in
                Just<[User]>([])
            }
            .eraseToAnyPublisher()
    }

    private func allUsersPublisher() -> AnyPublisher<[User], Never> {
        storageManager.allUsersPublisher()
            .catch { _ in
                Just<[User]>([])
            }
            .eraseToAnyPublisher()
    }

    private func recipesPublisher() -> AnyPublisher<[OnlineRecipe], Never> {
        let ids = filter == OnlineRecipeFilter.everyone
            ? userIds
            : (filter == OnlineRecipeFilter.followees
                ? followeeIds
                : [USER_ID])

        return $filter.combineLatest($followeeIds, $userIds).map { [self] _, _, _
            -> AnyPublisher<[OnlineRecipe], Error> in
            storageManager.allRecipesByUsersPublisher(userIds: ids)
        }
        .map { recipesPublisher in
            recipesPublisher.catch { _ in
                Just<[OnlineRecipe]>([])
            }
        }
        .switchToLatest()
        .eraseToAnyPublisher()

//        storageManager.allRecipesByUsersPublisher(userIds: ids)
//            .catch { _ in
//                Just<[OnlineRecipe]>([])
//            }
//            .eraseToAnyPublisher()
    }

}

enum OnlineRecipeFilter: String, CaseIterable {
    case everyone = "Everyone"
    case followees = "From who you're following"
    case own = "Self"
}
