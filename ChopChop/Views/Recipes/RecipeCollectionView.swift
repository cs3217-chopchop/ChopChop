import SwiftUI

struct RecipeCollectionView: View {
    @ObservedObject var viewModel: RecipeCollectionViewModel

    var body: some View {
        VStack {
            SearchBar(text: $viewModel.query, placeholder: "Search recipes...")
            List(viewModel.recipes) { recipe in
                NavigationLink(
                    destination: RecipeDetailView(name: recipe.name)
                ) {
                    HStack(alignment: .top) {
                        Image("recipe")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .cornerRadius(10)
                            .clipped()
                        VStack(alignment: .leading) {
                            Text(recipe.name)
                            Text("Absolutely delish")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding([.top, .bottom], 8)
                }
            }
        }
        .navigationTitle(Text(viewModel.category.name))
        .onDisappear {
            viewModel.query = ""
        }
    }
}

struct RecipeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeCollectionView(viewModel: RecipeCollectionViewModel(category: RecipeCategory(name: "")))
    }
}
