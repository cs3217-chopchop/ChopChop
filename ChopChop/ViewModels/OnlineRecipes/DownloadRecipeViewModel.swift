import Foundation

class DownloadRecipeViewModel: ObservableObject {
    @Published var recipeNameToSave = ""
    @Published var recipeToDownload: OnlineRecipe?
    @Published var isShow = false
    @Published var errorMessage = ""
    private let storageManager = StorageManager()
    @Published var isNewDownload = true
    var forkedRecipesCheckList: CheckListViewModel<Recipe>?

    func setRecipe(recipe: OnlineRecipe) {
        recipeToDownload = recipe
        isShow = true
        recipeNameToSave = recipe.name
        errorMessage = ""
        isNewDownload = true
    }

    func downloadRecipe() {
        do {
            guard let recipe = recipeToDownload else {
                return
            }
            try storageManager.downloadRecipe(newName: recipeNameToSave, recipe: recipe) { _ in
                self.errorMessage = "Couldn't download"
                return
            }
            resetFields()
        } catch {
            errorMessage = "Invalid name"
        }
    }

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
