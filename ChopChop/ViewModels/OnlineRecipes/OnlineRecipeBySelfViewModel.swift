import SwiftUI
import Combine

/**
 Represents a view model of a view of a recipe published online by the current user.
 */
class OnlineRecipeBySelfViewModel: OnlineRecipeViewModel {
    private let reload: () -> Void

    init(recipe: OnlineRecipe, downloadRecipeViewModel: DownloadRecipeViewModel, settings: UserSettings,
         reload: @escaping () -> Void) {
        self.reload = reload
        super.init(recipe: recipe, downloadRecipeViewModel: downloadRecipeViewModel, settings: settings)
    }

    /**
     Unpublishes the displayed recipe.
     */
    func onDelete() {
        try? storageManager.removeOnlineRecipe(recipe: recipe) { err in
            guard err == nil else {
                return
            }
            self.reload()
        }
    }
}
