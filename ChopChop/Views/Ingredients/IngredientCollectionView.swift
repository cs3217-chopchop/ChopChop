import SwiftUI

struct IngredientCollectionView: View {
    @ObservedObject var viewModel: IngredientCollectionViewModel

    var body: some View {
        VStack {
            SearchBar(text: $viewModel.query, placeholder: "Search ingredients...")
            List(viewModel.ingredients) { ingredient in
                IngredientRow(ingredient: ingredient)
            }
        }
        .navigationTitle(Text(viewModel.title))
        .onDisappear {
            viewModel.query = ""
        }
    }

    func IngredientRow(ingredient: IngredientInfo) -> some View {
        NavigationLink(
            destination: Text(ingredient.name)
        ) {
            HStack(alignment: .top) {
                Image("recipe")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
                    .clipped()
                VStack(alignment: .leading) {
                    Text(ingredient.name)
                    Text("2.5 kg")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding([.top, .bottom], 6)
        }
    }
}

struct IngredientCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        IngredientCollectionView(viewModel: IngredientCollectionViewModel(title: ""))
    }
}
