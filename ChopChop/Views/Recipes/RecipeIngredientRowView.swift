import SwiftUI
import Combine

struct RecipeIngredientRowView: View {
    @ObservedObject var viewModel: RecipeIngredientRowViewModel

    var body: some View {
        HStack {
            quantity
            Picker("Unit", selection: $viewModel.unit) {
                ForEach(QuantityType.allCases, id: \.self) {
                    Text($0.description)
                }
            }
            .pickerStyle(MenuPickerStyle())
            Spacer()
            Text(viewModel.unit.description)
            TextField("Ingredient", text: $viewModel.ingredientName)
        }
    }

    var quantity: some View {
        TextField("Quantity", text: $viewModel.amount)
    }
}

struct RecipeIngredientRowView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeIngredientRowView(viewModel: RecipeIngredientRowViewModel())
    }
}
