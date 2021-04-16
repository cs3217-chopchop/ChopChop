import Foundation

class DownloadRecipeViewModel: ObservableObject {
    @Published var recipeNameToSave = ""
    @Published var recipeToDownload: OnlineRecipe?
    @Published var isShow = false
    @Published var errorMessage = ""
    private let storageManager = StorageManager()

    func setRecipe(recipe: OnlineRecipe) {
        recipeToDownload = recipe
        isShow = true
        recipeNameToSave = recipe.name
        errorMessage = ""
    }

    func downloadRecipe() {
        do {
            guard let recipe = recipeToDownload else {
                assertionFailure()
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

    private func resetFields() {
        recipeToDownload = nil
        isShow = false
        recipeNameToSave = ""
        errorMessage = ""
    }
}
