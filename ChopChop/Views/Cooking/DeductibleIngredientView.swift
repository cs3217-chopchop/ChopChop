import SwiftUI

struct DeductibleIngredientView: View {
    @StateObject var viewModel: DeductibleIngredientViewModel

    var body: some View {
        Section(footer: errorMessage) {
            HStack {
                HStack {
                    TextField("Quantity", text: Binding(get: { viewModel.quantity },
                                                        set: viewModel.setQuantity))
                        .keyboardType(.decimalPad)
                    Picker(viewModel.unit.description, selection: $viewModel.unit) {
                        ForEach(QuantityUnit.allCases, id: \.self) {
                            Text($0.description)
                        }
                    }
                    .frame(width: 60, alignment: .leading)
                    .pickerStyle(MenuPickerStyle())
                }
                .frame(width: 140)
                Text(viewModel.ingredient.name)
            }
        }
    }

    @ViewBuilder
    var errorMessage: some View {
        if !viewModel.errorMessages.isEmpty {
            Text(viewModel.errorMessages.joined(separator: "\n"))
                .foregroundColor(.red)
        }
    }
}

struct DeductibleIngredientView_Previews: PreviewProvider {
    static var previews: some View {
        if let ingredient = try? Ingredient(name: "Butter", type: .count),
           let quantity = try? Quantity(.count, value: 2),
           let recipeIngredient = try? RecipeIngredient(name: "Butter", quantity: quantity) {
                DeductibleIngredientView(viewModel: DeductibleIngredientViewModel(ingredient: ingredient,
                                                                                  recipeIngredient: recipeIngredient))
        }
    }
}
