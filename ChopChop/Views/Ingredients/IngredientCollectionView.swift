import SwiftUI

struct IngredientCollectionView: View {
    @EnvironmentObject var settings: UserSettings
    @ObservedObject var viewModel: IngredientCollectionViewModel

    let columns = [
        GridItem(),
        GridItem(),
        GridItem(),
        GridItem()
    ]

    var body: some View {
        VStack {
            SearchBar(text: $viewModel.query, placeholder: "Search ingredients...")
            HStack {
                NavigationLink(
                    destination: IngredientFormView(
                        viewModel: IngredientFormViewModel(
                            addToCategory: viewModel.categoryId))) {
                    Image(systemName: "plus")
                }
                Spacer()
                Button(action: {
                    withAnimation {
                        viewModel.filterByExpiryDate.toggle()
                    }
                }) {
                    Text("Filter by expiry date")
                }
            }
            .padding([.leading, .trailing])

            if viewModel.filterByExpiryDate {
                expiryDatePicker
            }

            if viewModel.ingredients.isEmpty {
                notFoundView
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
            HStack {
                Text("View type:")
                Picker("View by", selection: $settings.viewType) {
                    Text("List").tag(UserSettings.ViewType.list)
                    Text("Grid").tag(UserSettings.ViewType.grid)
                }
            }
        }
        .alert(isPresented: $viewModel.alertIsPresented) {
            Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage))
        }
        .onAppear {
            viewModel.query = ""
            viewModel.filterByExpiryDate = false
            viewModel.expiryDateStart = .today
            viewModel.expiryDateEnd = .today
        }
    }

    var expiryDatePicker: some View {
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
        .padding([.leading, .trailing])
    }

    var notFoundView: some View {
        VStack(spacing: 10) {
            Image(systemName: "text.badge.xmark")
                .font(.system(size: 60))
            Text("No ingredients found")
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .foregroundColor(.secondary)
    }

    var listView: some View {
        List {
            ForEach(viewModel.ingredients) { ingredient in
                IngredientRow(info: ingredient)
            }
            .onDelete(perform: viewModel.deleteIngredients)
            .animation(.none)
        }
    }

    var gridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 24) {
                ForEach(viewModel.ingredients) { ingredient in
                    GridTile(info: ingredient)
                }
            }
            .padding([.bottom, .leading, .trailing])
        }
        .padding(.top)
    }

    @ViewBuilder
    func IngredientRow(info: IngredientInfo) -> some View {
        if let ingredient = viewModel.getIngredient(info: info) {
            NavigationLink(
                destination: IngredientDetail(ingredient: ingredient)
            ) {
                HStack(alignment: .top) {
                    Image(uiImage: viewModel.getIngredientImage(ingredient: ingredient))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .cornerRadius(10)
                        .clipped()
                    VStack(alignment: .leading) {
                        Text(ingredient.name)
                            .lineLimit(1)
                        Text("Quantity: \(ingredient.totalQuantityDescription)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding([.top, .bottom], 6)
            }
        }
    }

    @ViewBuilder
    func GridTile(info: IngredientInfo) -> some View {
        if let ingredient = viewModel.getIngredient(info: info) {
            NavigationLink(
                destination: IngredientDetail(ingredient: ingredient)
            ) {
                Image(uiImage: viewModel.getIngredientImage(ingredient: ingredient))
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fill)
                    .cornerRadius(10)
                    .clipped()
                    .overlay(
                        ZStack(alignment: .bottomLeading) {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(stops: [
                                            .init(color: .clear, location: 0),
                                            .init(color: .black, location: 0.5)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(10)
                                .opacity(0.8)
                            VStack(alignment: .leading) {
                                Text(ingredient.name)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                Text("Quantity: \(ingredient.totalQuantityDescription)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                        }
                    )
                    .padding([.leading, .trailing], 8)
            }
            .contextMenu {
                Button(action: {
                    guard let index = viewModel.ingredients.firstIndex(where: { $0 == info }) else {
                        return
                    }

                    viewModel.deleteIngredients(at: [index])
                }) {
                    Label("Delete Ingredient", systemImage: "trash")
                }
            }
        }
    }

    func IngredientDetail(ingredient: Ingredient) -> some View {
        let ingredientViewModel = IngredientViewModel(ingredient: ingredient)
        return IngredientDetailView(viewModel: ingredientViewModel)
    }
}

struct IngredientCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        IngredientCollectionView(viewModel: IngredientCollectionViewModel(title: ""))
    }
}
