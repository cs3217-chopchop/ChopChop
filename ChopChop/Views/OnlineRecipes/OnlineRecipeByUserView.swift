import SwiftUI

struct OnlineRecipeByUserView: View {
    @ObservedObject var viewModel: OnlineRecipeByUserViewModel

    var body: some View {
        VStack {
            Text(viewModel.creatorName)
            OnlineRecipeView(viewModel: viewModel)
            ratings
            downloadButton
        }.background(EmptyView().sheet(isPresented: $viewModel.isDownload) {
            // get new recipe name from user
            TextField("Save as", text: $viewModel.saveAs)
            Text(viewModel.errorMessage)
                .foregroundColor(.red)
        })
    }

    var ratings: some View {
        HStack {
            Text("Own rating")
            StarsView(rating: viewModel.ownRating?.score.rawValue ?? 0, maxRating: RatingScore.excellent.rawValue, onTap: viewModel.tapRating)
        }
    }

    var downloadButton: some View {
        Button(action: {
            viewModel.isDownload = true
        }) {
            Image(systemName: "square.and.arrow.down")
        }
    }
}

struct OnlineRecipeByUserView_Previews: PreviewProvider {
    static var previews: some View {
        OnlineRecipeByUserView()
    }
}
