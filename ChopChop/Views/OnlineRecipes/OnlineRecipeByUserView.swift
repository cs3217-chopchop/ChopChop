import SwiftUI

struct OnlineRecipeByUserView: View {
    @StateObject var viewModel: OnlineRecipeByUserViewModel

    var body: some View {
        VStack(spacing: 0) {
            OnlineRecipeView(viewModel: viewModel)

            Divider()

            if viewModel.isShowingRating {
                rateRecipeBar
            } else {
                rateRecipeButton
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 40)
                .stroke(Color.primary, lineWidth: 4)
        )
        .padding([.vertical], 50)
        .padding([.horizontal], 100)
    }

    var rateRecipeBar: some View {
        HStack {
            StarsView(rating: Double(viewModel.ownRating?.score.rawValue ?? 0),
                      maxRating: RatingScore.max, onTap: viewModel.tapRating)
                .frame(width: 200, height: 40, alignment: .center)

            if viewModel.ownRating != nil {
                Button("Remove Rating", action: viewModel.removeRating)
            } else {
                Button("Close", action: viewModel.toggleShowRating)
            }
        }
        .padding()
    }

    var rateRecipeButton: some View {
        Button(action: viewModel.toggleShowRating) {
            Label("Rate Recipe", systemImage: "star")
        }
        .padding()
    }
}
