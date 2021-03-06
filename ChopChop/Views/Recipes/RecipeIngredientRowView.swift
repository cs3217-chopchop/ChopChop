import SwiftUI
import Combine

/**
 Represents a view of an ingredient required to make a recipe.
 */
struct RecipeIngredientRowView: View {
    @StateObject var viewModel: RecipeIngredientRowViewModel

    var body: some View {
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
            .frame(width: 120)
            TextField("Name", text: $viewModel.name)
                .autocapitalization(.none)
        }
    }
}

struct RecipeIngredientRowView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeIngredientRowView(viewModel: RecipeIngredientRowViewModel())
    }
}
