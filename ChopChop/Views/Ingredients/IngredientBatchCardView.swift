import SwiftUI

struct IngredientBatchCardView: View {
    let viewModel: IngredientBatchViewModel

    var body: some View {
        HStack {
            Text(viewModel.quantityDescription)
            Spacer()
            expiryDateLabel
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.secondary, lineWidth: 1)
        )
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
