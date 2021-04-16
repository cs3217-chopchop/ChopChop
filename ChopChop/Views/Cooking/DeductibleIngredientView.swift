import SwiftUI

struct DeductibleIngredientView: View {
    @ObservedObject var viewModel: DeductibleIngredientViewModel

    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Spacer()
                Text(viewModel.ingredient.name)
                    .frame(width: 100, height: 30)
                TextField(viewModel.ingredient.name, text: $viewModel.deductBy)
                    .keyboardType(.decimalPad)
                    .foregroundColor(viewModel.errorMsg.isEmpty ? .primary : .red)
                    .frame(width: 100, height: 50, alignment: .center)
                    .border(Color.primary, width: 1)
                    .multilineTextAlignment(.center)
                Menu(viewModel.unit.description) {
                    ForEach(QuantityUnit.allCases, id: \.description) { type in
                        Button(action: {
                            viewModel.updateUnit(unit: type)
                        }) {
                            Text(type.description)
                        }
                    }
                }.frame(width: 100, height: 30)
                Spacer()
            }
            Text(viewModel.errorMsg)
                .foregroundColor(.red)
                .frame(width: 400, height: 20)
        }
    }
}

struct DeductibleIngredientView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable force_try line_length
        DeductibleIngredientView(viewModel: DeductibleIngredientViewModel(ingredient: try! Ingredient(name: "Butter", type: .count, batches: []), recipeIngredient: try! RecipeIngredient(name: "Butter", quantity: try! Quantity(.count, value: 2))))
    }
}
