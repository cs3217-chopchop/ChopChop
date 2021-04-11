import SwiftUI
import Combine

class OnlineRecipeBySelfViewModel: OnlineRecipeViewModel {

    let reload: () -> Void

    init(recipe: OnlineRecipe, downloadRecipeViewModel: DownloadRecipeViewModel, settings: UserSettings,
         reload: @escaping () -> Void) {
        self.reload = reload
        super.init(recipe: recipe, downloadRecipeViewModel: downloadRecipeViewModel, settings: settings)
    }

    func onDelete() {
        do {
            try storageManager.removeOnlineRecipe(recipe: recipe, completion: reload)
        } catch {
            assertionFailure("Could not remove recipe from online")
        }
    }

}
