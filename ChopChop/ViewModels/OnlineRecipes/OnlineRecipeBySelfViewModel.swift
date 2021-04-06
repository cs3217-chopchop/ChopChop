import SwiftUI
import Combine

class OnlineRecipeBySelfViewModel: OnlineRecipeViewModel {

    func onDelete() {
        do {
            try storageManager.removeRecipeFromOnline(recipe: recipe)
        } catch {
            assertionFailure("Could not remove recipe from online")
        }
    }

}
