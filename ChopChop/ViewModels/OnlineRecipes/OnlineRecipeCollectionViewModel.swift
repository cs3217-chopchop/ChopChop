import Foundation
import SwiftUI
import Combine

final class OnlineRecipeCollectionViewModel: ObservableObject {
    private let filter: OnlineRecipeCollectionFilter?
    private let userIds: [String]?
    @Published private(set) var recipes: [OnlineRecipe] = []

    private let storageManager = StorageManager()
    private let settings: UserSettings

    @Published var downloadRecipeViewModel = DownloadRecipeViewModel()
    @Published var isLoading = false

    @ObservedObject private(set) var onlineRecipeCollectionEditor = OnlineRecipeCollectionEditor()
    private var editorCancellable: AnyCancellable?

    init(filter: OnlineRecipeCollectionFilter, settings: UserSettings) {
        self.filter = filter
        self.userIds = nil
        self.settings = settings
    }

    init(userIds: [String], settings: UserSettings) {
        self.userIds = userIds
        self.filter = nil
        self.settings = settings

        editorCancellable = onlineRecipeCollectionEditor.$onlineRecipeToDelete
            .sink { [weak self] recipe in
                guard let id = recipe?.id else {
                    return
                }
                self?.recipes.removeAll { $0.id == id }
                self?.onlineRecipeCollectionEditor.onlineRecipeToDelete = nil
            }
    }

    init(recipe: OnlineRecipe, settings: UserSettings) {
        self.recipes = [recipe]
        self.settings = settings
        self.userIds = nil
        self.filter = nil
    }

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
        }
    }

}

enum OnlineRecipeCollectionFilter: String {
    case everyone = "Discover"
    case followees = "Recipes from followees"
}
