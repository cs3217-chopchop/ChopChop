import SwiftUI

struct DeductibleIngredientView: View {
    @ObservedObject var viewModel: DeductibleIngredientViewModel

    var body: some View {
        HStack {
            // TODO
            Text(viewModel.ingredient.name + " (" + "units" + ")")
            TextField(viewModel.ingredient.name, text: $viewModel.deductBy)
                .keyboardType(.decimalPad)
                .foregroundColor(viewModel.isError ? .red : .black)
                .frame(width: 200, height: 50, alignment: .center)
                .border(Color.black, width: 1)
                .padding()
        }
    }
}

struct DeductibleIngredientView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable force_try line_length
        DeductibleIngredientView(viewModel: DeductibleIngredientViewModel(ingredient: try! Ingredient(name: "Butter", type: .count, batches: []), estimatedQuantity: 4))
    }
}
