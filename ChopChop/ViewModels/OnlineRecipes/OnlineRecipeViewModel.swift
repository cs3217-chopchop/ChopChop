import SwiftUI
import Combine

/**
 Represents a view model of a view of a recipe published online.
 */
class OnlineRecipeViewModel: ObservableObject {
    /// The published recipe displayed in the view.
    private(set) var recipe: OnlineRecipe
    /// The recipe from which the displayed recipe was downloaded from
    /// Is `nil` if the displayed recipe was not downloaded from another published recipe.
    private(set) var parentRecipe: OnlineRecipe?
    /// The recipes that were downloaded from the displayed recipe.
    private(set) var downloadedRecipes: [Recipe] = []

    /// The view model in charge of downloading recipes.
    @Published var downloadRecipeViewModel: DownloadRecipeViewModel
    /// A flag representing whether the data is still being loaded from storage.
    @Published var isLoading = false

    /// Displayed recipe details
    @Published private(set) var recipeServingText = ""
    @Published private(set) var creatorName = ""
    @Published private var ratings: [RecipeRating] = []
    @Published private var firstRater = ""
    @Published private(set) var image = UIImage(imageLiteralResourceName: "recipe")

    /// Display flags
    @Published var isShowingDetail = false

    let settings: UserSettings
    let storageManager = StorageManager()

    init(recipe: OnlineRecipe, downloadRecipeViewModel: DownloadRecipeViewModel, settings: UserSettings) {
        self.recipe = recipe
        self.downloadRecipeViewModel = downloadRecipeViewModel
        self.settings = settings
        reload()
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

    /**
     Sets the displayed recipe to be downloaded.
     */
    func setRecipeToBeDownloaded() {
        downloadRecipeViewModel.setRecipe(recipe: recipe)
    }

    /**
     Loads the recipe to be displayed.
     */
    func load() {
        isLoading = true
        updateRating()
        updateImage()
        updateCreatorName()
        updateRecipeServingText()
        updateParentOnlineRecipe()
    }

    /**
     Reloads the recipe to be displayed.
     */
    func reload() {
        isLoading = true
        storageManager.fetchOnlineRecipe(id: recipe.id) { onlineRecipe, _ in
            guard let onlineRecipe = onlineRecipe else {
                return
            }
            self.recipe = onlineRecipe
            self.updateRating()
            self.updateImage()
            self.updateCreatorName()
            self.updateRecipeServingText()
            self.updateParentOnlineRecipe()
        }
    }

    /**
     Updates all local recipes that were downloaded from the displayed recipe.
     */
    func updateForkedRecipes() {
        downloadRecipeViewModel.updateForkedRecipes(recipes: downloadedRecipes, onlineRecipe: recipe)
    }

    func toggleShowDetail() {
        isShowingDetail.toggle()
    }

    private func updateDownloadedRecipes() {
        downloadedRecipes = (try? storageManager.fetchDownloadedRecipes(parentOnlineRecipeId: recipe.id)) ?? []
    }

    private func updateParentOnlineRecipe() {
        guard let parentId = recipe.parentOnlineRecipeId else {
            return
        }
        storageManager.fetchOnlineRecipe(id: parentId) { onlineRecipe, _ in
            self.parentRecipe = onlineRecipe
        }
    }

    private func updateRecipeServingText() {
        recipeServingText = "\(recipe.servings.removeZerosFromEnd()) \(recipe.servings == 1 ? "person" : "people")"
    }

    private func updateCreatorName() {
        guard recipe.creatorId != settings.userId  else {
            creatorName = settings.user?.name ?? ""
            return
        }

        storageManager.fetchUser(id: recipe.creatorId) { user, err in
            guard let name = user?.name, err == nil else {
                return
            }
            self.creatorName = name
        }
    }

    private func updateImage() {
        storageManager.fetchOnlineRecipeImage(recipeId: recipe.id) { data, err  in
            guard let data = data, let image = UIImage(data: data), err == nil else {
                self.image = UIImage(imageLiteralResourceName: "recipe")
                self.isLoading = false // takes the longest
                return
            }
            self.image = image
            self.isLoading = false // takes the longest
        }
    }

    private func updateRating() {
        ratings = recipe.ratings

        guard let firstRaterId = getRaterId(recipe: recipe) else {
            return
        }

        storageManager.fetchUser(id: firstRaterId) { user, err in
            guard let name = user?.name, err == nil else {
                return
            }
            self.firstRater = (self.settings.userId == firstRaterId ? "You" : name)
        }
    }

    /**
     Returns the id of a user who rated the displayed recipe, or `nil` if the recipe has not been rated by any user.

     If multiple users have rated the recipe, the id returned follows this list with decreasing priority:
     - A random followee of the current user.
     - A random user.
     - The current user.
     */
    private func getRaterId(recipe: OnlineRecipe) -> String? {
        guard let userId = settings.userId, let followees = settings.user?.followees else {
            return nil
        }

        if let raterId = (ratings.first { followees.contains($0.userId) })?.userId {
            return raterId
        }

        if let raterId = (ratings.first { $0.userId != userId })?.userId {
            return raterId
        }

        if (ratings.contains { $0.userId == userId }) {
            return userId
        }

        return nil
    }
}
