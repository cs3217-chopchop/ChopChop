import SwiftUI

struct IngredientCollectionView: View {
    @ObservedObject var viewModel: IngredientCollectionViewModel

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

            List(viewModel.ingredients) { ingredient in
                IngredientRow(ingredient: ingredient)
            }
            .animation(.none)
        }
        .navigationTitle(Text(viewModel.title))
        .onDisappear {
            viewModel.query = ""
            viewModel.filterByExpiryDate = false
            viewModel.expiryDateStart = Calendar.current.startOfDay(for: Date())
            viewModel.expiryDateEnd = Calendar.current.startOfDay(for: Date())
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
}

struct IngredientCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        IngredientCollectionView(viewModel: IngredientCollectionViewModel(title: ""))
    }
}
