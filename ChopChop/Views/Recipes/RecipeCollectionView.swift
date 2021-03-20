import SwiftUI

struct RecipeCollectionView: View {
    @ObservedObject var viewModel: RecipeCollectionViewModel

    var body: some View {
        VStack {
            SearchBar(text: $viewModel.query, placeholder: "Search recipes...")
            HStack {
                Spacer()
                MultiselectPicker("Filter by ingredient",
                                  selections: $viewModel.selectedIngredients,
                                  options: viewModel.recipeIngredients)
            }
            .padding([.leading, .trailing])
            List(viewModel.recipes) { recipe in
                RecipeRow(recipe: recipe)
            }
        }
        .navigationTitle(Text(viewModel.title))
        .onDisappear {
            viewModel.query = ""
            viewModel.selectedIngredients.removeAll()
        }
    }

    func RecipeRow(recipe: RecipeInfo) -> some View {
        NavigationLink(
            destination: Text(recipe.name)
        ) {
            HStack(alignment: .top) {
                Image("recipe")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .cornerRadius(10)
                    .clipped()
                VStack(alignment: .leading) {
                    let servingNumber = Int.random(in: 1...4)

                    Text(recipe.name)
                    VStack(alignment: .leading) {
                        Text("Serves \(servingNumber)-\(servingNumber + Int.random(in: 1...2)) people")
                        HStack(spacing: 0) {
                            let rating = Int.random(in: 2...6)

                            ForEach(1..<rating) { _ in
                                Image(systemName: "star.fill")
                            }

                            ForEach(rating..<6) { _ in
                                Image(systemName: "star")
                            }
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .padding([.top, .bottom], 6)
        }
    }
}

struct RecipeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeCollectionView(viewModel: RecipeCollectionViewModel(title: ""))
    }
}
