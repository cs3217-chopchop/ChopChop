import SwiftUI

struct IngredientDetailView: View {
    let viewModel: IngredientViewModel

    var body: some View {
        NavigationView {
            EmptyView()

            VStack {
                ZStack(alignment: .bottomLeading) {
                    Rectangle()
                        .frame(height: 300)
                        .opacity(0.3)
                    Text(viewModel.ingredientName)
                        .font(.largeTitle)
                        .padding()
                }

                IngredientBatchGridView(viewModel: viewModel)
            }
            .toolbar {
                NavigationLink(destination: addBatchView) {
                    Image(systemName: "plus")
                }

                NavigationLink(destination: editIngredientView) {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
    }

    var editIngredientView: some View {
        let ingredientFormViewModel = IngredientFormViewModel(edit: viewModel.ingredient)
        return IngredientFormView(viewModel: ingredientFormViewModel)
    }

    @ViewBuilder
    var addBatchView: some View {
        if let batchFormViewModel = try? IngredientBatchFormViewModel(
                addBatchOfType: viewModel.ingredient.quantityType) {
            IngredientBatchFormView(viewModel: batchFormViewModel)
        }
    }
}

struct IngredientDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable force_try
        IngredientDetailView(
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
