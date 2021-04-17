import SwiftUI

class SessionRecipeViewModel: ObservableObject {
    @Published var showDetailsPanel = true
    @Published var sheetIsPresented = false
    @Published var isComplete = false

    let sessionRecipe: SessionRecipe

    init(recipe: Recipe) {
        sessionRecipe = SessionRecipe(recipe: recipe)
    }
}
