import SwiftUI
import Combine

class OnlineRecipeBySelfViewModel: OnlineRecipeViewModel {
    private let onlineRecipeCollectionEditor: OnlineRecipeCollectionEditor

    init(recipe: OnlineRecipe, downloadRecipeViewModel: DownloadRecipeViewModel, settings: UserSettings, editor: OnlineRecipeCollectionEditor) {
        self.onlineRecipeCollectionEditor = editor
        super.init(recipe: recipe, downloadRecipeViewModel: downloadRecipeViewModel, settings: settings)
        _ = self.objectWillChange.append(super.objectWillChange)
    }

    func onDelete() {
        do {
            try storageManager.removeOnlineRecipe(recipe: recipe) { err in
                guard err == nil else {
                    return
                }
                self.onlineRecipeCollectionEditor.onlineRecipeToDelete = self.recipe
            }
        } catch {
            assertionFailure("Could not remove recipe from online")
        }
    }

}
