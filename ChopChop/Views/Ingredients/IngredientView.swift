import SwiftUI

struct IngredientView: View {
    @ObservedObject var viewModel: IngredientViewModel

    var body: some View {
        if let ingredient = viewModel.ingredient {
            VStack {
                ingredientBanner(ingredient)
                toolbar
                Divider()
                ingredientBatches(ingredient)

                NavigationLink(
                    destination: addBatchView(ingredient),
                    tag: .addBatch,
                    selection: $viewModel.activeFormView) {
                    EmptyView()
                }

                NavigationLink(
                    destination: editIngredientView(ingredient),
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
        } else {
            NotFoundView(entityName: "Ingredient")
        }
    }

    @ViewBuilder
    var image: some View {
        if let image = viewModel.image {
            Image(uiImage: image)
                .resizable()
        } else {
            Image("ingredient")
                .resizable()
        }
    }

    private func ingredientBanner(_ ingredient: Ingredient) -> some View {
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
            image
                .scaledToFill()
                .frame(height: 300)
                .clipped()
                .overlay(bannerOverlay)
            VStack(alignment: .leading) {
                Text(ingredient.name)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                Text(ingredient.quantityType.description)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .padding()
        }
    }

    var toolbar: some View {
        HStack {
            Button(action: { viewModel.activeFormView = .addBatch }) {
                Label("Add Batch", systemImage: "plus")
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
                Label("Delete...", systemImage: "trash")
            }
        }
        .padding(EdgeInsets(top: 2, leading: 16, bottom: 2, trailing: 16))
    }

    private func ingredientBatches(_ ingredient: Ingredient) -> some View {
        let columns: [GridItem] = [GridItem(.adaptive(minimum: 250))]

        return ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(ingredient.batches, id: \.expiryDate) { batch in
                    let batchViewModel = IngredientBatchViewModel(batch: batch)
                    let batchFormViewModel = IngredientBatchFormViewModel(
                        edit: batch,
                        quantityType: ingredient.quantityType,
                        ingredientViewModel: viewModel)

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

    private func editIngredientView(_ ingredient: Ingredient) -> some View {
        let ingredientFormViewModel = IngredientFormViewModel(edit: ingredient)
        return IngredientFormView(viewModel: ingredientFormViewModel)
    }

    @ViewBuilder
    private func addBatchView(_ ingredient: Ingredient) -> some View {
        if let batchFormViewModel = try? IngredientBatchFormViewModel(
            addBatchTo: viewModel,
            quantityType: ingredient.quantityType) {
            IngredientBatchFormView(viewModel: batchFormViewModel)
        }
    }
}
