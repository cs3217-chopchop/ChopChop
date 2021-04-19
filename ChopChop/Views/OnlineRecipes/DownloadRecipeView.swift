import SwiftUI

/**
 Represents a view of a form for downloading a published recipe.
 */
struct DownloadRecipeView: View {
    @ObservedObject var viewModel: DownloadRecipeViewModel

    var body: some View {
        if viewModel.isNewDownload {
            downloadNewCopyView
        } else {
            updateExistingCopyView
        }

    }

    private var downloadNewCopyView: some View {
        VStack {
            Text("Save as")
            TextField("New Recipe Name", text: $viewModel.recipeNameToSave)
                .frame(width: 400, height: 50, alignment: .center)
                .border(Color.primary, width: 1)
                .multilineTextAlignment(.center)
            Text(viewModel.errorMessage)
                .foregroundColor(.red)
            Button(action: {
                viewModel.downloadRecipe()
            }, label: {
                Text("Download Recipe")
            })
        }
    }

    private var updateExistingCopyView: some View {
        VStack {
            Text("""
                Please select existing recipes to update. Note that the update will \
                override all changes you have made to selected recipes.
                """
            )
            CheckListView(
                viewModel: viewModel.forkedRecipesCheckList ?? CheckListViewModel(checkList: [])
            )
            Text(viewModel.errorMessage)
                .foregroundColor(.red)
            Button(action: {
                viewModel.updateRecipes()
            }, label: {
                Text("Update Recipes")
            })
        }
    }
}

struct DownloadModal_Previews: PreviewProvider {
    static var previews: some View {
        DownloadRecipeView(viewModel: DownloadRecipeViewModel())
    }
}
