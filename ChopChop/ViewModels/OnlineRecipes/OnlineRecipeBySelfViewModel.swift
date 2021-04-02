import SwiftUI
import Combine

class OnlineRecipeBySelfViewModel: OnlineRecipeViewModel {

    func onDelete() {
        storageManager.removeRecipe(recipeId: recipe.id)
    }

}
