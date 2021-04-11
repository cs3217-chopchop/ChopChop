import SwiftUI
import Combine

class OnlineRecipeBySelfViewModel: OnlineRecipeViewModel {

    func onDelete() {
        do {
            try storageManager.removeRecipeFromOnline(recipe: recipe, completion: reload)
        } catch {
            assertionFailure("Could not remove recipe from online")
        }
    }

}
