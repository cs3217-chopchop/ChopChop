import SwiftUI

struct DeductibleIngredientView: View {
    @ObservedObject var viewModel: DeductibleIngredientViewModel

    var body: some View {
        HStack(alignment: .center) {
            Text(viewModel.ingredient.name)
            VStack {
                TextField(viewModel.ingredient.name, text: $viewModel.deductBy)
                    .keyboardType(.decimalPad)
                    .foregroundColor(viewModel.errorMsg.isEmpty ? .black : .red)
                    .frame(width: 100, height: 50, alignment: .center)
                    .border(Color.black, width: 1)
                    .multilineTextAlignment(.center)

                Text(viewModel.errorMsg)
                    .foregroundColor(.red)
            }
            Menu(viewModel.unit.nonEmptyDescription) {
                ForEach(QuantityType.allCases, id: \.description) { type in
                    Button(action: {
                        viewModel.updateUnit(unit: type)
                    }) {
                        Text(type.nonEmptyDescription)
                    }
                }
            }
        }
    }
}

struct DeductibleIngredientView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable force_try line_length
        DeductibleIngredientView(viewModel: DeductibleIngredientViewModel(ingredient: try! Ingredient(name: "Butter", type: .count, batches: []), recipeIngredient: try! RecipeIngredient(name: "Butter", quantity: try! Quantity(.count, value: 2))))
    }
}
