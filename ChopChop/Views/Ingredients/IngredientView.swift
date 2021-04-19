import SwiftUI

/**
 Represents a view of an ingredient.
 */
struct IngredientView: View {
    @StateObject var viewModel: IngredientViewModel

    var body: some View {
        if let ingredient = viewModel.ingredient {
            VStack {
                ingredientBanner(ingredient)
                batchToolbar
                Divider()
                ingredientBatches(ingredient)

                addBatchLink(ingredient)
                editIngredientLink(ingredient)
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

    // MARK: - Ingredient Banner

    private func ingredientBanner(_ ingredient: Ingredient) -> some View {
        let bannerOverlay: some View = Rectangle()
            .foregroundColor(.clear)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .clear, .black]),
                    startPoint: .top,
                    endPoint: .bottom))

        return ZStack(alignment: .bottomLeading) {
            image
                .scaledToFill()
                .frame(height: 300)
                .clipped()
                .overlay(bannerOverlay)
            ingredientDetails(ingredient)
        }
    }

    private func ingredientDetails(_ ingredient: Ingredient) -> some View {
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

    @ViewBuilder
    private var image: some View {
        if let image = viewModel.image {
            Image(uiImage: image)
                .resizable()
        } else {
            Image("ingredient")
                .resizable()
        }
    }

    // MARK: - Batch Toolbar

    private var batchToolbar: some View {
        HStack {
            addBatchButton
            Spacer()
            deleteBatchMenu
        }
        .padding(EdgeInsets(top: 2, leading: 16, bottom: 2, trailing: 16))
    }

    private var addBatchButton: some View {
        Button(action: { viewModel.activeFormView = .addBatch }) {
            Label("Add Batch", systemImage: "plus")
        }
    }

    private var deleteBatchMenu: some View {
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

    // MARK: - Ingredient Batches

    private func ingredientBatches(_ ingredient: Ingredient) -> some View {
        let columns: [GridItem] = [GridItem(.adaptive(minimum: 250))]

        return ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(ingredient.batches, id: \.expiryDate) { batch in
                    batchTile(batch, ingredient: ingredient)
                }
            }
            .padding()
        }
    }

    private func batchTile(_ batch: IngredientBatch, ingredient: Ingredient) -> some View {
        let batchViewModel = IngredientBatchViewModel(batch: batch)
        let batchFormViewModel = IngredientBatchFormViewModel(
            edit: batch,
            quantityType: ingredient.quantityType,
            ingredientViewModel: viewModel)

        return HStack(spacing: 0) {
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

    // MARK: - Forms

    private func addBatchLink(_ ingredient: Ingredient) -> some View {
        NavigationLink(
            destination: addBatchView(ingredient),
            tag: .addBatch,
            selection: $viewModel.activeFormView) {
            EmptyView()
        }
    }

    @ViewBuilder
    private func addBatchView(_ ingredient: Ingredient) -> some View {
        if let batchFormViewModel = try? IngredientBatchFormViewModel(
            addBatchTo: viewModel,
            quantityType: ingredient.quantityType) {
            IngredientBatchFormView(viewModel: batchFormViewModel)
        }
    }

    private func editIngredientLink(_ ingredient: Ingredient) -> some View {
        NavigationLink(
            destination: editIngredientView(ingredient),
            tag: .editIngredient,
            selection: $viewModel.activeFormView) {
            EmptyView()
        }
    }

    private func editIngredientView(_ ingredient: Ingredient) -> some View {
        let ingredientFormViewModel = IngredientFormViewModel(edit: ingredient)
        return IngredientFormView(viewModel: ingredientFormViewModel)
    }

}
