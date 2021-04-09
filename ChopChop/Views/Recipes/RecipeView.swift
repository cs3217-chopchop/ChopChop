import SwiftUI

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
            .toolbar {
                Menu {
                    Button(action: viewModel.publish) {
                        Label(viewModel.isPublished ? "Publish changes" : "Publish", systemImage: "icloud.and.arrow.up")
                    }

                    // TODO: Make this work
                    if viewModel.isPublished {
                        Button(action: {}) {
                            Label("Unpublish", systemImage: "icloud.slash")
                        }
                    }
                }
                label: {
                    Label("Publish", systemImage: "paperplane")
                }
            }
        } else {
            NotFoundView(entityName: "Recipe")
        }
    }

    @ViewBuilder
    var image: some View {
        if let image = viewModel.image {
            Image(uiImage: image)
                .resizable()
        } else {
            Image("recipe")
                .resizable()
        }
    }

    var banner: some View {
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

    func CaptionView(recipe: Recipe) -> some View {
        HStack {
            Text("Serves \(recipe.servings.removeZerosFromEnd())")
            Divider()
            DifficultyView(difficulty: recipe.difficulty)
            Divider()
            Text(recipe.category?.name ?? "Uncategorised")
                .lineLimit(1)
            Divider()

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

    func DetailsView(recipe: Recipe) -> some View {
        VStack(alignment: .leading) {
            IngredientsView(recipe: recipe)
            StepsView(recipe: recipe)
        }
        .padding([.leading, .trailing])
    }

    func IngredientsView(recipe: Recipe) -> some View {
        VStack(alignment: .leading) {
            Text("Ingredients")
                .font(.title)
                .padding(.bottom, 4)
            VStack(alignment: .leading) {
                ForEach(recipe.ingredients, id: \.name) { ingredient in
                    Text(ingredient.description)
                }
            }
            .padding(.bottom)
        }
    }

    func StepsView(recipe: Recipe) -> some View {
        VStack(alignment: .leading) {
            Text("Steps")
                .font(.title)
                .padding(.bottom, 4)
            VStack(alignment: .leading) {
                ForEach(0..<recipe.stepGraph.nodes.count, id: \.self) { idx in
                    HStack(alignment: .top) {
                        Text("Step \(idx + 1):")
                            .bold()
                        Text(recipe.stepGraph.topologicallySortedNodes[idx].label.content)
                    }
                }
            }
            .padding(.bottom)
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
    }
}

struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeView(viewModel: RecipeViewModel(id: 1, settings: UserSettings()))
    }
}
