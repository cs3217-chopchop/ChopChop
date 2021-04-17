import SwiftUI

struct OnlineRecipeView: View {
    @ObservedObject var viewModel: OnlineRecipeViewModel

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
        .onAppear {
            viewModel.load()
        }
    }

    var userBar: some View {
        NavigationLink(
            destination: ProfileView(viewModel: ProfileViewModel(userId: viewModel.recipe.userId, settings: viewModel.settings))
        ) {
            HStack {
                Image("default-user")
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

    var recipeImage: some View {
        Image(uiImage: viewModel.image)
            .resizable()
            .scaledToFill()
            .frame(height: 300)
            .clipped()
            .overlay(recipeImageOverlay)
    }

    var recipeImageOverlay: some View {
        var recipeName: some View {
            Text(viewModel.recipe.name)
                .font(.title)
                .foregroundColor(.white)
                .lineLimit(1)
        }

        var recipeDetails: some View {
            VStack(alignment: .leading) {
                Text("Serves \(viewModel.recipe.servings.removeZerosFromEnd()) \(viewModel.recipe.servings == 1 ? "person" : "people")")
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

        return ZStack(alignment: .bottomLeading) {
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
                recipeDetails
            }
            .padding()
        }
    }

    var averageRating: some View {
        HStack {
            Text("Rating: ")
            StarsView(rating: viewModel.averageRating, maxRating: RatingScore.max)
                .frame(width: 150, height: 30)
            Text(viewModel.ratingDetails)
            Spacer()
            downloadButton
        }.padding()
    }

    var recipeDetails: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("Ingredients").font(.title).underline()
                ingredient
                Spacer()
                Text("Instructions").font(.title).underline()
                instruction
            }
            .padding()

            Spacer()
        }
    }

    var ingredient: some View {
        VStack(alignment: .leading) {
            ForEach(viewModel.recipe.ingredients, id: \.self.description) { ingredient in
                Text("• \(ingredient.description)")
            }
        }.font(.body)
    }

    var instruction: some View {
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

    var showDetailBar: some View {
        Button(action: viewModel.toggleShowDetail) {
            HStack {
                Image(systemName: viewModel.isShowingDetail ? "chevron.up" : "chevron.down")
                Text(viewModel.isShowingDetail ? "Hide Details" : "Show Details")
            }
        }
        .padding()
    }

    var downloadButton: some View {
        Button(action: viewModel.setRecipe) {
            Label("Download", systemImage: "square.and.arrow.down")
        }
    }
}
