import SwiftUI
import Combine

class OnlineRecipeBySelfViewModel: OnlineRecipeViewModel {

    func onDelete() {
        try? storageManager.removeRecipeFromOnline(recipe: recipe)
    }

}
