import Foundation

class DownloadRecipeViewModel: ObservableObject {

    @Published var recipeNameToSave = ""
    @Published var recipeToDownload: OnlineRecipe?
    @Published var isShow = false {
        didSet {
            print("gonna show")
        }
    }
    @Published var errorMessage = ""
    private let storageManager = StorageManager()

    func setRecipe(recipe: OnlineRecipe) {
        recipeToDownload = recipe
        isShow = true
        recipeNameToSave = ""
        errorMessage = ""
    }

    func downloadRecipe() {
        do {
            guard let recipe = recipeToDownload else {
                assertionFailure()
                return
            }
            try storageManager.downloadRecipe(newName: recipeNameToSave, recipe: recipe)
            recipeToDownload = nil
            isShow = false
            recipeNameToSave = ""
            errorMessage = ""
        } catch {
            errorMessage = "Invalid name"
        }
    }

}
