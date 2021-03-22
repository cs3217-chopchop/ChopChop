import SwiftUI

struct CompleteSessionRecipeView: View {
    @ObservedObject var viewModel: CompleteSessionRecipeViewModel

    var body: some View {
        VStack(alignment: .center) {
            Text("Ingredients to Deduct")
                .font(.largeTitle)
                .padding()
            ForEach(viewModel.deductibleIngredientsViewModels, id: \.ingredient.name) { deductibleIngredient in
                DeductibleIngredientView(viewModel: deductibleIngredient)
            }
            Button("Submit") {
                viewModel.submit()
            }.disabled(viewModel.isSuccess)
            .font(.title2)
            .padding()
            Text(viewModel.isSuccess ? "Success" : "")
                .foregroundColor(.green)
                .padding()
        }
    }
}

 struct CompleteSessionView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable force_try
        CompleteSessionRecipeView(viewModel: CompleteSessionRecipeViewModel(recipe: try! Recipe(name: "Pancakes")))
    }
 }
