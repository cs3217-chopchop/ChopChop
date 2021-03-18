import SwiftUI

struct IngredientDetailView: View {
    let viewModel: IngredientViewModel

    var body: some View {
        NavigationView {
            EmptyView()

            VStack {
                ZStack(alignment: .bottomLeading) {
                    Image(uiImage: viewModel.image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 300)
                        .clipped()
                        .overlay(
                            Rectangle()
                                .foregroundColor(.clear)
                                .background(LinearGradient(gradient: Gradient(colors: [.clear, .clear, .black]), startPoint: .top, endPoint: .bottom))
                        )
                    Text(viewModel.name)
                        .font(.largeTitle)
                        .foregroundColor(.white)
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
            addBatchTo: viewModel.ingredient) {
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
