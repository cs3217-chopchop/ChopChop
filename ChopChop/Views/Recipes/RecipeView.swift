import SwiftUI

/**
 Represents a view of a recipe.
 */
struct RecipeView: View {
    @ObservedObject var viewModel: RecipeViewModel

    var body: some View {
        if let recipe = viewModel.recipe {
            ScrollView {
                VStack(alignment: .leading) {
                    CaptionView(recipe: recipe)
                    banner
                    DetailsView(recipe: recipe)
                }
            }
            .navigationTitle(recipe.name)
            .background(navigationLinks(recipe))
            .toolbar {
                parentRecipeButton
                cookingButton
                editButton
                publishMenu
            }
        } else {
            NotFoundView(entityName: "Recipe")
        }
    }

    // MARK: - Caption

    private func CaptionView(recipe: Recipe) -> some View {
        HStack {
            Text("Serves \(recipe.servings.removeZerosFromEnd())")
            Divider()
            DifficultyView(difficulty: recipe.difficulty)
            Divider()
            Text(recipe.category?.name ?? "Uncategorised")
                .lineLimit(1)
            Divider()

            if recipe.totalTimeTaken != 0 {
                Text(viewModel.totalTimeTaken)
                Divider()
            }

            if viewModel.isPublished {
                Text("Published")
                    .foregroundColor(.accentColor)
            } else {
                Text("Unpublished")
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .font(.subheadline)
        .fixedSize(horizontal: false, vertical: true)
        .padding([.leading, .trailing])
    }

    // MARK: - Banner
    @ViewBuilder
    private var image: some View {
        if let image = viewModel.image {
            Image(uiImage: image)
                .resizable()
        } else {
            Image("recipe")
                .resizable()
        }
    }

    private var banner: some View {
        image
            .scaledToFill()
            .frame(height: 300)
            .clipped()
            .overlay(
                LinearGradient(
                    gradient: Gradient(
                        stops: [
                            .init(color: .init(UIColor.systemBackground), location: 0),
                            .init(color: Color(UIColor.systemBackground).opacity(0), location: 0.2),
                            .init(color: Color(UIColor.systemBackground).opacity(0), location: 0.8),
                            .init(color: .init(UIColor.systemBackground), location: 1)
                        ]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }

    // MARK: - Details

    private func DetailsView(recipe: Recipe) -> some View {
        VStack(alignment: .leading) {
            IngredientsView(recipe: recipe)
            StepsView(recipe: recipe)
        }
        .padding([.leading, .trailing])
    }

    private func IngredientsView(recipe: Recipe) -> some View {
        VStack(alignment: .leading) {
            Text("Ingredients")
                .font(.title)
                .padding(.bottom, 4)
            VStack(alignment: .leading) {
                if recipe.ingredients.isEmpty {
                    Text("No ingredients")
                } else {
                    ForEach(recipe.ingredients, id: \.name) { ingredient in
                        Text(ingredient.description)
                    }
                }
            }
            .padding(.bottom)
        }
    }

    private func StepsView(recipe: Recipe) -> some View {
        VStack(alignment: .leading) {
            Text("Steps")
                .font(.title)
                .padding(.bottom, 4)
            VStack(alignment: .leading) {
                if recipe.stepGraph.nodes.isEmpty {
                    Text("No steps")
                } else {
                    ForEach(0..<recipe.stepGraph.nodes.count, id: \.self) { idx in
                        HStack(alignment: .top) {
                            Text("Step \(idx + 1):")
                                .bold()
                            Text(recipe.stepGraph.topologicallySortedNodes[idx].label.content)
                        }
                    }
                    detailedStepsButton(recipe)
                }
            }
            .padding(.bottom)
        }
    }

    private func detailedStepsButton(_ recipe: Recipe) -> some View {
        HStack {
            Spacer()
            NavigationLink(
                destination: EditorGraphView(viewModel: EditorGraphViewModel(graph: recipe.stepGraph,
                                                                             isEditable: false))
            ) {
                Label("View detailed steps", systemImage: "rectangle.expand.vertical")
            }
            .padding()
            Spacer()
        }
    }

    // MARK: - Navigation Links

    private func navigationLinks(_ recipe: Recipe) -> some View {
        ZStack {
            NavigationLink(
                destination: SessionRecipeView(viewModel: SessionRecipeViewModel(recipe: recipe)),
                isActive: $viewModel.showSessionRecipe
            ) {
                EmptyView()
            }
            NavigationLink(
                destination: RecipeFormView(viewModel: RecipeFormViewModel(recipe: recipe)),
                isActive: $viewModel.showRecipeForm
            ) {
                EmptyView()
            }
            if let parentRecipe = viewModel.parentRecipe {
                NavigationLink(
                    destination: OnlineRecipeCollectionView(
                        viewModel: OnlineRecipeCollectionViewModel(
                            recipe: parentRecipe
                        )
                    ) {
                        EmptyView()
                    },
                    isActive: $viewModel.showParentRecipe
                ) {
                    EmptyView()
                }
            }
        }
    }

    // MARK: - Toolbar

    @ViewBuilder
    private var parentRecipeButton: some View {
        if viewModel.parentRecipe != nil {
            Button(action: {
                viewModel.showParentRecipe = true
            }) {
                Text("Adapted From")
            }
        }
    }

    @ViewBuilder
    private var cookingButton: some View {
        Button(action: {
            viewModel.showSessionRecipe = true
        }) {
            Image(systemName: "flame")
        }
        .disabled(viewModel.isCookingDisabled)
    }

    @ViewBuilder
    private var editButton: some View {
        Button(action: {
            viewModel.showRecipeForm = true
        }) {
            Image(systemName: "square.and.pencil")
        }
    }

    @ViewBuilder
    private var publishMenu: some View {
        Menu {
            Button(action: viewModel.publish) {
                Label(viewModel.isPublished ? "Publish changes" : "Publish",
                      systemImage: "icloud.and.arrow.up")
            }
        } label: {
            Image(systemName: "paperplane")
                .imageScale(.large)
                .padding(.leading, 8)
        }
    }
}

struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeView(viewModel: RecipeViewModel(id: 1, settings: UserSettings()))
    }
}
