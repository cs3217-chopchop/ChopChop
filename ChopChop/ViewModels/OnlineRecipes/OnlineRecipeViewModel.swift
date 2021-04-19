import SwiftUI
import Combine

class OnlineRecipeViewModel: ObservableObject {
    private(set) var recipe: OnlineRecipe

    private(set) var parentRecipe: OnlineRecipe?
    private(set) var downloadedRecipes: [Recipe] = []

    let storageManager = StorageManager()

    @Published private(set) var recipeServingText = ""
    @Published private(set) var creatorName = ""
    @Published private var ratings: [RecipeRating] = []
    @Published private var firstRater = ""
    @Published private(set) var image = UIImage(imageLiteralResourceName: "recipe")

    @Published var isShowingDetail = false

    let settings: UserSettings
    @Published var downloadRecipeViewModel: DownloadRecipeViewModel
    @Published var isLoading = false

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

    func setRecipe() {
        downloadRecipeViewModel.setRecipe(recipe: recipe)
    }

    func load() {
        isLoading = true
        updateRating()
        updateImage()
        updateCreatorName()
        updateRecipeServingText()
        updateParentOnlineRecipe()
        updateDownloadedRecipes()
    }

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
            self.updateDownloadedRecipes()
        }
    }

    func updateForkedRecipes() {
        updateDownloadedRecipes()
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

    private func getRaterId(recipe: OnlineRecipe) -> String? {
        guard let userId = settings.userId, let followees = settings.user?.followees else {
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
