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

//            Toggle(isOn: $viewModel.isSaveRecipe) {
//                Text("Make changes to recipe?")
//                    .font(.title2)
//                    .padding()
//            }
            .toggleStyle(CheckboxToggleStyle())

            Button("Submit") {
                viewModel.submit()
            }
            .font(.title2)
            .padding()
        }
    }
}

 struct CompleteSessionView_Previews: PreviewProvider {
    static func someFunction() {}
    static var previews: some View {
        // swiftlint:disable force_try
        CompleteSessionRecipeView(viewModel: CompleteSessionRecipeViewModel(recipe: try! Recipe(name: "Pancakes"), onClose: someFunction))
    }
 }
