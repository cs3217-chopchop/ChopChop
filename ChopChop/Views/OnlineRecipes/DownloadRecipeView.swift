import SwiftUI

struct DownloadRecipeView: View {
    @ObservedObject var viewModel: DownloadRecipeViewModel

    var body: some View {
        Text("Save as")
        TextField("New Recipe Name", text: $viewModel.saveAs)
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

struct DownloadModal_Previews: PreviewProvider {
    static var previews: some View {
        DownloadRecipeView(viewModel: DownloadRecipeViewModel())
    }
}
