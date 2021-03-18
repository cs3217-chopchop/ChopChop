import SwiftUI

struct RecipeCollectionView: View {
    @ObservedObject var viewModel: RecipeCollectionViewModel
    @Binding var selectedRecipe: RecipeInfo?

    var body: some View {
        VStack {
            TextField("Search", text: $viewModel.query)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            List(viewModel.recipes) { recipe in
                NavigationLink(
                    destination: RecipeDetailView(name: recipe.name),
                    tag: recipe,
                    selection: $selectedRecipe
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
        .navigationTitle(Text(viewModel.selectedCategory?.name ?? ""))
    }
}

struct RecipeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeCollectionView(viewModel: RecipeCollectionViewModel(selectedCategory: nil), selectedRecipe: .constant(nil))
    }
}
