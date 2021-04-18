import SwiftUI

/**
 Represents a view of a collection of ingredients.
 */
struct IngredientCollectionView: View {
    @EnvironmentObject var settings: UserSettings
    @ObservedObject var viewModel: IngredientCollectionViewModel

    var body: some View {
        VStack {
            SearchBar(text: $viewModel.query, placeholder: "Search ingredients...")
            ingredientToolbar

            if viewModel.filterByExpiryDate {
                expiryDatePicker
            }

            if viewModel.ingredients.isEmpty {
                NotFoundView(entityName: "Ingredients")
            } else {
                switch settings.viewType {
                case .list:
                    listView
                case .grid:
                    gridView
                }
            }
        }
        .navigationTitle(Text(viewModel.title))
        .toolbar {
            viewPicker
        }
        .alert(isPresented: $viewModel.alertIsPresented) {
            Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage))
        }
        .onAppear(perform: viewModel.resetSearchFields)
    }

    // MARK: - Toolbars

    private var viewPicker: some View {
        HStack {
            Text("View type:")
            Picker("View by", selection: $settings.viewType) {
                Text("List").tag(UserSettings.ViewType.list)
                Text("Grid").tag(UserSettings.ViewType.grid)
            }
        }
    }

    private var ingredientToolbar: some View {
        HStack {
            addIngredientButton
            Spacer()
            filterByExpiryDateButton
        }
        .padding([.leading, .trailing])
    }

    private var addIngredientButton: some View {
        NavigationLink(
            destination: IngredientFormView(
                viewModel: IngredientFormViewModel(
                    addToCategory: viewModel.categoryId))) {
            Image(systemName: "plus")
        }
    }

    private var filterByExpiryDateButton: some View {
        Button(action: {
            withAnimation {
                viewModel.filterByExpiryDate.toggle()
            }
        }) {
            Text("Filter by expiry date")
        }
    }

    private var expiryDatePicker: some View {
        HStack {
            Spacer()
            DatePicker(
                "Expires from:",
                selection: $viewModel.expiryDateStart,
                in: ...viewModel.expiryDateEnd,
                displayedComponents: [.date]
            )
            .fixedSize()
            DatePicker(
                "to",
                selection: $viewModel.expiryDateEnd,
                in: viewModel.expiryDateStart...,
                displayedComponents: [.date]
            )
            .fixedSize()
        }
        .padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
    }

    // MARK: - Ingredient Image

    @ViewBuilder
    private func IngredientImage(ingredient: IngredientInfo) -> some View {
        if let image = viewModel.getIngredientImage(ingredient: ingredient) {
            Image(uiImage: image)
                .resizable()
        } else {
            Image("ingredient")
                .resizable()
        }
    }

    // MARK: - Ingredient List View

    private var listView: some View {
        List {
            ForEach(viewModel.ingredients) { ingredient in
                IngredientRow(ingredient: ingredient)
            }
            .onDelete(perform: viewModel.deleteIngredients)
            .animation(.none)
        }
    }

    @ViewBuilder
    private func IngredientRow(ingredient: IngredientInfo) -> some View {
        if let id = ingredient.id {
            NavigationLink(
                destination: IngredientView(viewModel: IngredientViewModel(id: id))
            ) {
                HStack(alignment: .top) {
                    IngredientImage(ingredient: ingredient)
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .cornerRadius(10)
                        .clipped()
                    VStack(alignment: .leading) {
                        Text(ingredient.name)
                            .lineLimit(1)
                        Text("Quantity: \(ingredient.quantity)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding([.top, .bottom], 6)
            }
        }
    }

    // MARK: - Ingredient Grid View

    private var gridView: some View {
        let columns = [
            GridItem(),
            GridItem(),
            GridItem(),
            GridItem()
        ]

        return ScrollView {
            LazyVGrid(columns: columns, spacing: 24) {
                ForEach(viewModel.ingredients) { ingredient in
                    GridTile(ingredient: ingredient)
                }
            }
            .padding([.bottom, .leading, .trailing])
        }
    }

    @ViewBuilder
    private func GridTile(ingredient: IngredientInfo) -> some View {
        if let id = ingredient.id {
            NavigationLink(
                destination: IngredientView(viewModel: IngredientViewModel(id: id))
            ) {
                GridTileImage(ingredient: ingredient)
            }
            .contextMenu {
                Button(action: {
                    guard let index = viewModel.ingredients.firstIndex(where: { $0 == ingredient }) else {
                        return
                    }

                    viewModel.deleteIngredients(at: [index])
                }) {
                    Label("Delete Ingredient", systemImage: "trash")
                }
            }
        }
    }

    @ViewBuilder
    private func GridTileImage(ingredient: IngredientInfo) -> some View {
        IngredientImage(ingredient: ingredient)
            .scaledToFill()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fill)
            .cornerRadius(10)
            .clipped()
            .overlay(
                GridTileOverlay(ingredient: ingredient)
            )
            .padding([.leading, .trailing], 8)
    }

    private func GridTileOverlay(ingredient: IngredientInfo) -> some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .foregroundColor(.clear)
                .background(LinearGradient(gradient: Gradient(colors: [.clear, .black]),
                                           startPoint: .top,
                                           endPoint: .bottom))
                .cornerRadius(10)
                .opacity(0.8)
            VStack(alignment: .leading) {
                Text(ingredient.name)
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text("Quantity: \(ingredient.quantity)")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .padding()
        }
    }
}
