import SwiftUI

struct IngredientDetailView: View {
    @ObservedObject var viewModel: IngredientViewModel

    var body: some View {
        VStack(spacing: 0) {
            ingredientBanner
            toolbar
            Divider()
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
                Button(action: { viewModel.activeFormView = .editIngredient }) {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
    }

    var ingredientBanner: some View {
        var bannerOverlay: some View {
            Rectangle()
                .foregroundColor(.clear)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .clear, .black]),
                        startPoint: .top,
                        endPoint: .bottom))
        }

        return ZStack(alignment: .bottomLeading) {
            ingredientImage
                .scaledToFill()
                .frame(height: 300)
                .clipped()
                .overlay(bannerOverlay)
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

    @ViewBuilder
    var ingredientImage: some View {
        if let image = viewModel.ingredientImage {
            Image(uiImage: image)
                .resizable()
        } else {
            Image("ingredient")
                .resizable()
        }
    }

    var toolbar: some View {
        HStack {
            Button(action: { viewModel.activeFormView = .addBatch }) {
                Image(systemName: "plus")
            }

            Spacer()

            Menu {
                Button(action: viewModel.deleteAllBatches) {
                    Label("Delete All Batches", systemImage: "trash")
                }

                Button(action: viewModel.deleteExpiredBatches) {
                    Label("Delete Expired Batches", systemImage: "calendar")
                }
            }
            label: {
                Image(systemName: "trash")
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
        if let batchFormViewModel = try? IngredientBatchFormViewModel(addBatchTo: viewModel) {
            IngredientBatchFormView(viewModel: batchFormViewModel)
        }
    }
}

struct IngredientDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable force_try closure_body_length
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
