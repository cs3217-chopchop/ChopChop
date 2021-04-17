import SwiftUI
import Combine

class OnlineRecipeViewModel: ObservableObject {
    private(set) var recipe: OnlineRecipe

    let storageManager = StorageManager()

    @Published private(set) var recipeServingText = ""
    @Published private(set) var creatorName = "No name"

    @Published private var firstRater = "No name"
    @Published private(set) var image = UIImage(imageLiteralResourceName: "recipe")

    @Published var isShowingDetail: Bool = false

    let settings: UserSettings
    @Published var downloadRecipeViewModel: DownloadRecipeViewModel
    @Published var isLoading = false

    init(recipe: OnlineRecipe, downloadRecipeViewModel: DownloadRecipeViewModel, settings: UserSettings) {
        self.recipe = recipe
        self.downloadRecipeViewModel = downloadRecipeViewModel
        self.settings = settings
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
        storageManager.fetchOnlineRecipe(id: recipe.id) { onlineRecipe, _ in
            guard let onlineRecipe = onlineRecipe else {
                return
            }
            self.recipe = onlineRecipe
            self.updateFirstRaterName()
            self.updateImage()
            self.updateCreatorName()
            self.updateRecipeServingText()
        }
    }

    func toggleShowDetail() {
        isShowingDetail.toggle()
    }

    private func updateRecipeServingText() {
        recipeServingText = "\(recipe.servings.removeZerosFromEnd()) \(recipe.servings == 1 ? "person" : "people")"
    }

    private func updateCreatorName() {
        guard recipe.userId != settings.userId  else {
            creatorName = settings.user?.name ?? "No name"
            return
        }
        storageManager.fetchUser(id: recipe.userId) { user, err in
            guard let name = user?.name, err == nil else {
                return
            }
            self.creatorName = name
        }
    }

    private func updateImage() {
        storageManager.fetchOnlineRecipeImage(recipeId: recipe.id) { data, err  in
            guard let data = data, let image = UIImage(data: data), err == nil else {
                return
            }
            self.image = image
            self.isLoading = false // takes the longest
        }
    }

    private func updateFirstRaterName() {
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
