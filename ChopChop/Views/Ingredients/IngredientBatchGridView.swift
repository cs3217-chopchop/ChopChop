import SwiftUI

struct IngredientBatchGridView: View {
    let viewModel: IngredientViewModel

    var body: some View {
        let columns: [GridItem] = [GridItem(.adaptive(minimum: 250))]

        return ScrollView {
             LazyVGrid(columns: columns) {
                ForEach(viewModel.ingredientBatches, id: \.expiryDate) { batch in
                    let batchViewModel = IngredientBatchViewModel(batch: batch)
                    let batchFormViewModel = IngredientBatchFormViewModel(edit: batch, ingredientViewModel: viewModel)

                    HStack(spacing: 0) {
                        NavigationLink(destination: IngredientBatchFormView(viewModel: batchFormViewModel)) {
                            IngredientBatchCardView(viewModel: batchViewModel)
                                .padding()
                        }

                        Divider()

                        Button(action: { viewModel.deleteBatch(expiryDate: batch.expiryDate) }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .padding()
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.secondary, lineWidth: 1)
                    )
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
