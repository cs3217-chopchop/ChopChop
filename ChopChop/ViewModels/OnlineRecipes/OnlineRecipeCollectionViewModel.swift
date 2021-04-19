import Foundation
import SwiftUI
import Combine

/**
 Represents a view model of a view of a collection of recipes published online.
 */
final class OnlineRecipeCollectionViewModel: ObservableObject {
    /// The recipes displayed in the view.
    @Published private(set) var recipes: [OnlineRecipe] = []
    /// The filter applied to the collection of all published recipes.
    /// Is `nil` if this collection of recipes is not filtered in this way.
    private let filter: OnlineRecipeCollectionFilter?
    /// The recipes displayed is the union of all recipes published by the users identified by their ids in this array.
    /// Is `nil` if this collection of recipes is not obtained in this way.
    private let userIds: [String]?

    private let storageManager = StorageManager()
    private let settings: UserSettings

    /// The view model in charge of downloading recipes.
    @Published var downloadRecipeViewModel = DownloadRecipeViewModel()
    /// A flag representing whether the data is still being loaded from storage.
    @Published var isLoading = false

    init(filter: OnlineRecipeCollectionFilter, settings: UserSettings) {
        self.filter = filter
        self.userIds = nil
        self.settings = settings
    }

    init(userIds: [String], settings: UserSettings) {
        self.filter = nil
        self.userIds = userIds
        self.settings = settings
    }

    init(recipe: OnlineRecipe, settings: UserSettings) {
        self.filter = nil
        self.userIds = nil
        self.recipes = [recipe]
        self.settings = settings
    }

    /**
     Loads the recipes in the collection.
     */
    func load() {
        isLoading = true
        if let userIds = userIds {
            storageManager.fetchOnlineRecipes(userIds: userIds) { onlineRecipes, _ in
                self.recipes = onlineRecipes
                self.isLoading = false
            }
            return
        } else if filter == .everyone {
            storageManager.fetchAllOnlineRecipes { onlineRecipes, _ in
                self.recipes = onlineRecipes
                self.isLoading = false
            }
        } else if filter == .followees {
            storageManager.fetchOnlineRecipes(userIds: settings.user?.followees ?? []) { onlineRecipes, _ in
                self.recipes = onlineRecipes
                self.isLoading = false
            }
        } else {
            self.isLoading = false
        }
    }
}

enum OnlineRecipeCollectionFilter: String {
    case everyone = "Discover"
    case followees = "Recipes from followees"
}
