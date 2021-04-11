import SwiftUI
import Combine

class OnlineRecipeViewModel: ObservableObject {
    private(set) var recipe: OnlineRecipe
    @Published private var firstRater = "No name"
    @Published private(set) var image = UIImage(imageLiteralResourceName: "recipe")

    let storageManager = StorageManager()
    let settings: UserSettings
    @Published var downloadRecipeViewModel: DownloadRecipeViewModel

    init(recipe: OnlineRecipe, downloadRecipeViewModel: DownloadRecipeViewModel, settings: UserSettings) {
        self.recipe = recipe
        self.downloadRecipeViewModel = downloadRecipeViewModel
        self.settings = settings

        updateFirstRaterName()
        updateImage()
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

    func reload() {
        storageManager.fetchOnlineRecipe(onlineRecipeId: recipe.id) { onlineRecipe, _ in
            guard let onlineRecipe = onlineRecipe else {
                return
            }
            self.recipe = onlineRecipe
            self.updateFirstRaterName()
            self.updateImage()
        }
    }

    private func updateImage() {
        storageManager.fetchOnlineRecipeImage(recipeId: recipe.id) { data in
            guard let image = UIImage(data: data) else {
                return
            }
            self.image = image
        }
    }

    private func updateFirstRaterName() {
        guard let firstRaterId = getRaterId(recipe: recipe) else {
            return
        }
        storageManager.fetchUserInfoById(userId: firstRaterId) { user, _ in
            guard let name = user?.name else {
                return
            }
            self.firstRater = (self.settings.userId == user?.id ? "You" : name)
        }
    }

    private func getRaterId(recipe: OnlineRecipe) -> String? {
        guard let userId = settings.userId, let followees = settings.user?.followees else {
            assertionFailure()
            return nil
        }
        if let raterId = (recipe.ratings.first { followees.contains($0.userId) })?.userId {
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
