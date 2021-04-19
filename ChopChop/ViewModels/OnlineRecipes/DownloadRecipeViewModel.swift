import Foundation

/**
 Represents a view model for a view of a form for downloading a published recipe.
 */
class DownloadRecipeViewModel: ObservableObject {
    /// The name of the downloaded recipe.
    @Published var recipeNameToSave = ""
    /// The recipe to be downloaded.
    @Published var recipeToDownload: OnlineRecipe?
    /// A flag representing whether the recipe has been downloaded before.
    @Published var isNewDownload = true
    /// A view model containing the list of recipes downloaded from the published recipe.
    var forkedRecipesCheckList: CheckListViewModel<Recipe>?

    /// Display flags
    @Published var isShow = false

    /// Alert fields
    @Published var errorMessage = ""

    private let storageManager = StorageManager()

    /**
     Sets the details of the form with the given published recipe.
     */
    func setRecipe(recipe: OnlineRecipe) {
        recipeToDownload = recipe
        isShow = true
        recipeNameToSave = recipe.name
        errorMessage = ""
        isNewDownload = true
    }

    /**
     Downloads the published recipe.
     */
    func downloadRecipe() {
        do {
            guard let recipe = recipeToDownload else {
                return
            }

            try storageManager.downloadRecipe(newName: recipeNameToSave, recipe: recipe) { _ in
                self.errorMessage = "Download failed"
                return
            }

            resetFields()
        } catch {
            errorMessage = "Invalid name"
        }
    }

    /**
     Updates the selected recipes that previously downloaded the published recipe.
     */
    func updateRecipes() {
        guard let recipe = recipeToDownload, let checkList = forkedRecipesCheckList else {

            return
        }
        do {
            for checkListItem in checkList.checkList where checkListItem.isChecked {
                try storageManager.updateForkedRecipes(forked: checkListItem.item, original: recipe)
            }
            isShow = false
            recipeToDownload = nil
        } catch {
            errorMessage = "Error updating recipes"
        }
    }

    /**
     Updates the given recipes that previously downloaded the given published recipe.
     */
    func updateForkedRecipes(recipes: [Recipe], onlineRecipe: OnlineRecipe) {
        forkedRecipesCheckList = CheckListViewModel(checkList: recipes.map({
            CheckListItem(item: $0, displayName: $0.name)
        }))
        errorMessage = ""
        recipeToDownload = onlineRecipe
        isShow = true
        isNewDownload = false
    }

    private func resetFields() {
        recipeToDownload = nil
        isShow = false
        recipeNameToSave = ""
        errorMessage = ""
    }
}
