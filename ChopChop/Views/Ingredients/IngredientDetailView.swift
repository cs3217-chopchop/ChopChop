import SwiftUI

struct IngredientDetailView: View {
    @ObservedObject var viewModel: IngredientViewModel

    var body: some View {
        VStack {
            ingredientBanner
            IngredientBatchGridView(viewModel: viewModel)

            NavigationLink(
                destination: addBatchView,
                tag: .addBatch,
                selection: $viewModel.activeFormView) {
                EmptyView()
            }

            NavigationLink(
                destination: editIngredientView,
                tag: .editIngredient,
                selection: $viewModel.activeFormView) {
                EmptyView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.activeFormView = .addBatch }) {
                    Image(systemName: "plus")
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.activeFormView = .editIngredient }) {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
    }

    var ingredientBanner: some View {
        ZStack(alignment: .bottomLeading) {
            Image(uiImage: viewModel.ingredientImage)
                .resizable()
                .scaledToFill()
                .frame(height: 300)
                .clipped()
                .overlay(
                    Rectangle()
                        .foregroundColor(.clear)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .clear, .black]),
                                startPoint: .top,
                                endPoint: .bottom))
                )
            VStack(alignment: .leading) {
                Text(viewModel.ingredientName)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                Text(viewModel.ingredient.quantityType.description)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .padding()
        }
    }

    var toolbar: some View {
        HStack {
            Spacer()
            NavigationLink(destination: addBatchView) {
                Image(systemName: "plus")
            }
            NavigationLink(destination: editIngredientView) {
                Image(systemName: "square.and.pencil")
            }
        }
        .padding()
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
        Group {
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
}
