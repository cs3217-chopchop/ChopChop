import Foundation

class DownloadRecipeViewModel: ObservableObject {

    @Published var saveAs = ""
    @Published var recipeToDownload: OnlineRecipe?
    @Published var isShow = false
    @Published var errorMessage = ""
    private let storageManager = StorageManager()

    func setRecipe(recipe: OnlineRecipe) {
        recipeToDownload = recipe
        isShow = true
        saveAs = ""
        errorMessage = ""
    }

    func downloadRecipe() {
        do {
            guard let recipe = recipeToDownload else {
                assertionFailure()
                return
            }
            try storageManager.downloadRecipe(newName: saveAs, recipe: recipe)
            recipeToDownload = nil
            isShow = false
            errorMessage = ""
        } catch {
            errorMessage = "Invalid name"
        }
    }

}
