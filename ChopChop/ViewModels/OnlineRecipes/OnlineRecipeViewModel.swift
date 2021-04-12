import SwiftUI
import Combine

class OnlineRecipeViewModel: ObservableObject {
    private(set) var recipe: OnlineRecipe
    private(set) var downloadedRecipes: [Recipe]
    private var recipeCancellable: AnyCancellable?
    private var followeesCancellable: AnyCancellable?
    private var firstRaterCancellable: AnyCancellable?
    private var imageCancellable: AnyCancellable?
    let storageManager = StorageManager()

    @Published private var firstRater = "No name"
    private var followeeIds: [String] = []

    @Published private(set) var image = UIImage(imageLiteralResourceName: "recipe")

    let settings: UserSettings

    @Published var downloadRecipeViewModel: DownloadRecipeViewModel

    init(recipe: OnlineRecipe, downloadRecipeViewModel: DownloadRecipeViewModel, settings: UserSettings) {
        self.recipe = recipe
        self.downloadRecipeViewModel = downloadRecipeViewModel
        self.settings = settings
        do {
            self.downloadedRecipes = try storageManager.fetchDownloadedRecipes(parentId: recipe.id)
        } catch {
            self.downloadedRecipes = []
        }

        followeesCancellable = followeesPublisher()
            .sink { [weak self] followees in
                self?.followeeIds = followees.compactMap { $0.id }
            }

        recipeCancellable = onlineRecipePublisher()
            .sink { [weak self] recipe in
                self?.recipe = recipe

                guard let firstRaterId = self?.getRaterId(recipe: recipe) else {
                    return
                }

                self?.firstRaterCancellable = self?.firstRaterPublisher(firstRaterId: firstRaterId)
                    .sink { [weak self] user in
                        self?.firstRater = (settings.userId == firstRaterId ? "You" : user.name)
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

    func setRecipe() {
        downloadRecipeViewModel.setRecipe(recipe: recipe)
    }

    func updateForkedRecipes() {
        downloadRecipeViewModel.updateForkedRecipes(recipes: downloadedRecipes, onlineRecipe: recipe)
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
        guard let userId = settings.userId else {
            fatalError("No user id stored")
        }

        return storageManager.allFolloweesPublisher(userId: userId)
            .catch { _ in
                Just<[User]>([])
            }
            .eraseToAnyPublisher()
    }

    private func imagePublisher() -> AnyPublisher<UIImage, Never> {
        storageManager.onlineRecipeImagePublisher(recipeId: recipe.id)
            .catch { _ in
                Just<UIImage>(UIImage(imageLiteralResourceName: "recipe"))
            }
            .eraseToAnyPublisher()
    }

    private func getRaterId(recipe: OnlineRecipe) -> String? {
        guard let userId = settings.userId else {
            assertionFailure()
            return nil
        }
        if let raterId = (recipe.ratings.first { followeeIds.contains($0.userId) })?.userId {
            // return 1 of followees
            return raterId
        }
        if let raterId = (recipe.ratings.first { $0.userId != userId })?.userId {
            // return any rater thats not ownself
            return raterId
        }
        if (recipe.ratings.contains { $0.userId == userId }) {
            return userId
        }
        return nil
    }

}
