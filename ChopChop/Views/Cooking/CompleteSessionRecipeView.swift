import SwiftUI

struct CompleteSessionRecipeView: View {
    @ObservedObject var viewModel: CompleteSessionRecipeViewModel

    var body: some View {
        VStack {
            Text("Deduct Ingredients")
                .font(.title)
                .padding()

            if viewModel.deductibleIngredients.isEmpty {
                NotFoundView(entityName: "Deductible Ingredients")
            } else {
                ScrollView {
                    ForEach(viewModel.deductibleIngredients, id: \.self) { recipeIngredientViewModel in
                        DeductibleIngredientView(viewModel: recipeIngredientViewModel)
                    }
                }
            }

            Button("Complete Recipe") {
                if !viewModel.deductibleIngredients.isEmpty {
                    viewModel.submit()
                }
            }
        }
        .padding()
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}

struct CompleteSessionView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable force_try
        CompleteSessionRecipeView(viewModel: CompleteSessionRecipeViewModel(recipe: try! Recipe(name: "Pancakes")))
    }
}
