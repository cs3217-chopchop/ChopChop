import SwiftUI

struct IngredientBatchGridView: View {
    let viewModel: IngredientViewModel

    var body: some View {
        let columns: [GridItem] = [GridItem(.adaptive(minimum: 250))]

        return ScrollView {
             LazyVGrid(columns: columns) {
                ForEach(viewModel.ingredientBatches, id: \.expiryDate) { batch in
                    let batchViewModel = IngredientBatchViewModel(batch: batch)
                    let batchFormViewModel = IngredientBatchFormViewModel(edit: batch, in: viewModel.ingredient)
                    NavigationLink(destination: IngredientBatchFormView(viewModel: batchFormViewModel)) {
                        IngredientBatchCardView(viewModel: batchViewModel)
                    }
                }
             }
             .padding()
        }
    }
}

struct IngredientBatchGridView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable force_try
        IngredientBatchGridView(
            viewModel: IngredientViewModel(
                ingredient: try! Ingredient(
                    name: "Apple",
                    type: .count,
                    batches: [
                        IngredientBatch(
                            quantity: try! Quantity(.count, value: 3),
                            expiryDate: Date()),
                        IngredientBatch(
                            quantity: try! Quantity(.count, value: 3)),
                        IngredientBatch(
                            quantity: try! Quantity(.count, value: 3),
                            expiryDate: Date().addingTimeInterval(100_000)),
                        IngredientBatch(
                            quantity: try! Quantity(.count, value: 3),
                            expiryDate: Date().addingTimeInterval(200_000))
                    ])))
    }
}
