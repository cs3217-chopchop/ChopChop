import SwiftUI

/**
 Represents a view of a batch of an ingredient.
 */
struct IngredientBatchCardView: View {
    let viewModel: IngredientBatchViewModel

    var body: some View {
        HStack {
            Text(viewModel.quantityDescription)
            Spacer()
            expiryDateLabel
        }
    }

    @ViewBuilder
    var expiryDateLabel: some View {
        if let dateDescription = viewModel.expiryDateDescription {
            Label(dateDescription, systemImage: "calendar")
        }
    }
}

struct IngredientBatchCardView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable force_try
        IngredientBatchCardView(
            viewModel: IngredientBatchViewModel(
                batch: IngredientBatch(
                    quantity: try! Quantity(.count, value: 3),
                    expiryDate: Date())))
    }
}
