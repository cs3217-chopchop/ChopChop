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
                ExpiryDatePicker()
            }

            if viewModel.ingredients.isEmpty {
                NotFoundView()
            } else {
                switch settings.viewType {
                case .list:
                    ListView()
                case .grid:
                    GridView()
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
        .onDisappear {
            viewModel.query = ""
            viewModel.filterByExpiryDate = false
            viewModel.expiryDateStart = .today
            viewModel.expiryDateEnd = .today
        }
    }

    func ExpiryDatePicker() -> some View {
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

    func NotFoundView() -> some View {
        VStack(spacing: 10) {
            Image(systemName: "text.badge.xmark")
                .font(.system(size: 60))
            Text("No ingredients found")
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .foregroundColor(.secondary)
    }

    func ListView() -> some View {
        List(viewModel.ingredients) { ingredient in
            IngredientRow(ingredient: ingredient)
        }
        .animation(.none)
    }

    func IngredientRow(ingredient: IngredientInfo) -> some View {
        NavigationLink(
            destination: Text(ingredient.name)
        ) {
            HStack(alignment: .top) {
                Image("recipe")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .cornerRadius(10)
                    .clipped()
                VStack(alignment: .leading) {
                    Text(ingredient.name)
                        .lineLimit(1)
                    Text("2.5 kg")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding([.top, .bottom], 6)
        }
    }

    func GridView() -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 24) {
                ForEach(viewModel.ingredients) { ingredient in
                    NavigationLink(
                        destination: Text(ingredient.name)
                    ) {
                        GridTile(ingredient: ingredient)
                    }
                }
            }
            .padding([.bottom, .leading, .trailing])
        }
        .padding(.top)
    }

    func GridTile(ingredient: IngredientInfo) -> some View {
        Image("recipe")
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
                        Text("2.5 kg")
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
            )
            .padding([.leading, .trailing], 8)
    }
}

struct IngredientCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        IngredientCollectionView(viewModel: IngredientCollectionViewModel(title: ""))
    }
}
