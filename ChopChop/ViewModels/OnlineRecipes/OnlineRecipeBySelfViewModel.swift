import SwiftUI
import Combine

class OnlineRecipeBySelfViewModel: OnlineRecipeViewModel {
    private let reload: () -> Void

    init(recipe: OnlineRecipe, downloadRecipeViewModel: DownloadRecipeViewModel, settings: UserSettings, reload: @escaping () -> Void) {
        self.reload = reload
        super.init(recipe: recipe, downloadRecipeViewModel: downloadRecipeViewModel, settings: settings)
    }

    func onDelete() {
        try? storageManager.removeOnlineRecipe(recipe: recipe) { err in
            guard err == nil else {
                return
            }
            self.reload()
        }

    }

}
