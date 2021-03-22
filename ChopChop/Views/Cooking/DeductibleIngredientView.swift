import SwiftUI

struct DeductibleIngredientView: View {
    @ObservedObject var viewModel: DeductibleIngredientViewModel

    var body: some View {
        HStack {
            Text(viewModel.ingredient.name)
            TextField(viewModel.ingredient.name, text: $viewModel.deductBy)
                .keyboardType(.decimalPad)
                .foregroundColor(viewModel.isError ? .red : .black)
                .frame(width: 100, height: 50, alignment: .center)
                .border(Color.black, width: 1)
                .multilineTextAlignment(.center)
                .padding()
            Text(viewModel.recipeIngredient.quantity.type.description)
        }
    }
}

struct DeductibleIngredientView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable force_try line_length
        DeductibleIngredientView(viewModel: DeductibleIngredientViewModel(ingredient: try! Ingredient(name: "Butter", type: .count, batches: []), recipeIngredient: try! RecipeIngredient(name: "Butter", quantity: try! Quantity(.count, value: 2))))
    }
}
