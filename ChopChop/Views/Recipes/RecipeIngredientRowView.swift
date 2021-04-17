import SwiftUI
import Combine

struct RecipeIngredientRowView: View {
    @ObservedObject var viewModel: RecipeIngredientRowViewModel

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
        }
    }
}

struct RecipeIngredientRowView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeIngredientRowView(viewModel: RecipeIngredientRowViewModel())
    }
}
