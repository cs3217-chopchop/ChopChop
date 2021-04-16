import SwiftUI

class SessionRecipeViewModel: ObservableObject {
    @Published var showDetailsPanel = true

    let sessionRecipe: SessionRecipe

    init(recipe: Recipe) {
        sessionRecipe = SessionRecipe(recipe: recipe)
    }
}
