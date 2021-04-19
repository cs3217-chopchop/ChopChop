import SwiftUI

/**
 Represents a view of a recipe published online.
 */
struct OnlineRecipeView: View {
    @StateObject var viewModel: OnlineRecipeViewModel
    @EnvironmentObject var settings: UserSettings

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                userBar
                Divider()
                recipeImage
                averageRating
                if viewModel.isShowingDetail {
                    recipeDetails
                }
                Divider()
                showDetailBar
            }
            ProgressView(isShow: $viewModel.isLoading)
        }
    }

    // MARK: - User

    private var userBar: some View {
        NavigationLink(
            destination: ProfileView(
                viewModel: ProfileViewModel(
                    userId: viewModel.recipe.creatorId,
                    settings: viewModel.settings))
        ) {
            HStack {
                Image("user")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                Text(viewModel.creatorName)
                Spacer()
            }
            .padding()
        }
        .zIndex(1)
    }

    // MARK: - Image

    private var recipeImage: some View {
        Image(uiImage: viewModel.image)
            .resizable()
            .scaledToFill()
            .frame(height: 300)
            .clipped()
            .overlay(recipeImageOverlay)
    }

    private var recipeImageOverlay: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .foregroundColor(.clear)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .clear, .black]),
                        startPoint: .top,
                        endPoint: .bottom))
            HStack {
                recipeName
                Spacer()
                recipeInfo
            }
            .padding()
        }
    }

    private var recipeName: some View {
        VStack {
            Text(viewModel.recipe.name)
                .font(.title)
                .foregroundColor(.white)
                .lineLimit(1)
            if let parentRecipe = viewModel.parentRecipe {
                getLinkToParentRecipe(parentRecipe: parentRecipe)
            }
        }
    }

    private var recipeInfo: some View {
        VStack(alignment: .leading) {
            Text("Serves \(viewModel.recipeServingText)")
            HStack {
                Text("Difficulty: ")
                DifficultyView(difficulty: viewModel.recipe.difficulty)
            }
            HStack {
                Text("Cuisine: ")
                Text(viewModel.recipe.cuisine ?? "Unspecified")
            }
        }
        .font(.caption)
        .foregroundColor(.white)
    }

    // MARK: - Rating

    private var averageRating: some View {
        HStack {
            Text("Rating: ")
            StarsView(rating: viewModel.averageRating, maxRating: RatingScore.max)
                .frame(width: 150, height: 30)
            Text(viewModel.ratingDetails)
            Spacer()
            downloadButton
            if !viewModel.downloadedRecipes.isEmpty {
                updateButton
            }
        }.padding()
    }

    // MARK: - Details

    private var recipeDetails: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("Ingredients").font(.title).underline()
                ingredients
                Spacer()
                Text("Instructions").font(.title).underline()
                instructions
            }
            .padding()

            Spacer()
        }
    }

    private var ingredients: some View {
        VStack(alignment: .leading) {
            ForEach(viewModel.recipe.ingredients, id: \.self.description) { ingredient in
                Text("• \(ingredient.description)")
            }
        }.font(.body)
    }

    private var instructions: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(0..<viewModel.recipe.stepGraph.nodes.count, id: \.self) { idx in
                HStack(alignment: .top) {
                    Text("Step \(idx + 1):")
                        .bold()
                    Text(viewModel.recipe.stepGraph.topologicallySortedNodes[idx].label.content)
                }
            }.font(.body)
        }
    }

    // MARK: - Buttons

    private var showDetailBar: some View {
        Button(action: viewModel.toggleShowDetail) {
            HStack {
                Image(systemName: viewModel.isShowingDetail ? "chevron.up" : "chevron.down")
                Text(viewModel.isShowingDetail ? "Hide Details" : "Show Details")
            }
        }
        .padding()
    }

    private var downloadButton: some View {
        Button(action: viewModel.setRecipeToBeDownloaded) {
            Label("Download New Copy", systemImage: "square.and.arrow.down")
        }
    }

    private var updateButton: some View {
        Button(action: {
            viewModel.updateForkedRecipes()
        }) {
            Label("Update Downloaded Copies", systemImage: "square.and.arrow.down")
        }
    }

    // MARK: - Parent Recipe

    private func getLinkToParentRecipe(parentRecipe: OnlineRecipe) -> some View {
        NavigationLink(
            destination: OnlineRecipeCollectionView(
                viewModel: OnlineRecipeCollectionViewModel(
                    recipe: parentRecipe,
                    settings: settings
                )
            ) {
                EmptyView()
            }
        ) {
            Text("Adapted from here")
        }
    }
}
