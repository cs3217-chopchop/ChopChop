import SwiftUI

struct DeductibleIngredientView: View {
    @ObservedObject var viewModel: DeductibleIngredientViewModel

    var body: some View {
        HStack {
            Text(viewModel.ingredient.name)
            TextField(viewModel.ingredient.name, text: $viewModel.deductBy)
                .keyboardType(.decimalPad)
                .foregroundColor(.black)
                .frame(width: 200, height: 50, alignment: .center)
                .border(Color.black, width: 1)
            Text(viewModel.isError ? "Invalid Quantity" : "")
                .foregroundColor(.red)
        }
    }
}

struct DeductibleIngredientView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable force_try
        DeductibleIngredientView(viewModel: DeductibleIngredientViewModel(ingredient: try! Ingredient(name: "Butter", batches: [])))
    }
}
