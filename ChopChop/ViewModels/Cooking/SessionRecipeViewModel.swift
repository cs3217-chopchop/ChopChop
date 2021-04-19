import SwiftUI

/**
 Represents a view model of a view of a recipe being made.
 */
class SessionRecipeViewModel: ObservableObject {
    /// The recipe displayed in the view.
    let sessionRecipe: SessionRecipe
    /// A flag representing whether the recipe being made is complete.
    @Published var isComplete = false

    /// Display flags
    @Published var showDetailsPanel = true
    @Published var sheetIsPresented = false

    init(recipe: Recipe) {
        sessionRecipe = SessionRecipe(recipe: recipe)
    }
}
