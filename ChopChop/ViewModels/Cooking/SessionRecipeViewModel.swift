import SwiftUI

class SessionRecipeViewModel: ObservableObject {
    @Published var showDetailsPanel = true

    let recipe: SessionRecipe

    init(recipe: Recipe) {
        self.recipe = SessionRecipe(recipe: recipe)
    }
}
