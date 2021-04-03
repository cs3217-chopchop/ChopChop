import SwiftUI
import Combine

class OnlineRecipeViewModel: ObservableObject {
    private(set) var recipe: OnlineRecipe

    private var recipeCancellable: AnyCancellable?
    private var followeesCancellable: AnyCancellable?
    private var firstRaterCancellable: AnyCancellable?
    private var imageCancellable: AnyCancellable?
    let storageManager = StorageManager()

    @Published private var firstRater = "No name"
    private var followeeIds: [String] = []

    @Published private(set) var image = UIImage()

    init(recipe: OnlineRecipe) {
        self.recipe = recipe

        followeesCancellable = followeesPublisher()
            .sink { [weak self] followees in
                self?.followeeIds = followees.compactMap { $0.id }
            }

        recipeCancellable = onlineRecipePublisher()
            .sink { [weak self] recipe in
                self?.recipe = recipe

                // get name from followee list. otherwise get any name
                guard let firstRaterId = self?.getRaterId(recipe: recipe) else {
                    return
                }

                self?.firstRaterCancellable = self?.firstRaterPublisher(firstRaterId: firstRaterId)
                    .sink { [weak self] user in
                        self?.firstRater = (USER_ID == firstRaterId ? "You" : user.name)
                    }
            }

        imageCancellable = imagePublisher()
            .sink { [weak self] image in
                self?.image = image
            }
    }

    var averageRating: Double {
        guard !recipe.ratings.isEmpty else {
            return 0
        }
        return Double(recipe.ratings.map { $0.score.rawValue }.reduce(0, +)) / Double(recipe.ratings.count)
    }

    var ratingDetails: String {
        let ratingsCount = recipe.ratings.count
        if ratingsCount == 0 {
            return "(0 ratings)"
        } else if ratingsCount == 1 {
            return "(from " + firstRater + ")"
        } else {
            return "(from " + firstRater + " and " + String(ratingsCount - 1)
                + (ratingsCount == 2 ? " other)" : " others)")
        }
    }

    private func onlineRecipePublisher() -> AnyPublisher<OnlineRecipe, Never> {
        storageManager.onlineRecipeByIdPublisher(recipeId: recipe.id)
            .assertNoFailure()
            .eraseToAnyPublisher()
    }

    private func firstRaterPublisher(firstRaterId: String) -> AnyPublisher<User, Never> {
        storageManager.userByIdPublisher(userId: firstRaterId)
            .assertNoFailure()
            .eraseToAnyPublisher()
    }

    private func followeesPublisher() -> AnyPublisher<[User], Never> {
        guard let USER_ID = USER_ID else {
            fatalError()
        }

        return storageManager.allFolloweesPublisher(userId: USER_ID)
            .catch { _ in
                Just<[User]>([])
            }
            .eraseToAnyPublisher()
    }

    private func imagePublisher() -> AnyPublisher<UIImage, Never> {
        storageManager.onlineRecipeImagePublisher(recipeId: recipe.id)
            .catch { _ in
                Just<UIImage>(UIImage())
            }
            .eraseToAnyPublisher()
    }

    private func getRaterId(recipe: OnlineRecipe) -> String? {
        guard let USER_ID = USER_ID else {
            assertionFailure()
            return nil
        }
        if let raterId = (recipe.ratings.first(where: { _ in followeeIds.contains(USER_ID) }))?.userId {
            // return 1 of followees
            return raterId
        }
        if let raterId = (recipe.ratings.first(where: { recipeRating in recipeRating.userId != USER_ID }))?.userId {
            // return any rater thats not ownself
            return raterId
        }
        if recipe.ratings.contains(where: { recipeRating in recipeRating.userId == USER_ID }) {
            return USER_ID
        }
        return nil
    }

}
