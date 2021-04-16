// import SwiftUI
//
// struct IngredientBatchGridView: View {
//    let viewModel: IngredientViewModel
//
//    var body: some View {
//        let columns: [GridItem] = [GridItem(.adaptive(minimum: 250))]
//
//        return ScrollView {
//             LazyVGrid(columns: columns) {
//                ForEach(viewModel.ingredientBatches, id: \.expiryDate) { batch in
//                    let batchViewModel = IngredientBatchViewModel(batch: batch)
//                    let batchFormViewModel = IngredientBatchFormViewModel(edit: batch, in: viewModel.ingredient)
//                    NavigationLink(destination: IngredientBatchFormView(viewModel: batchFormViewModel)) {
//                        IngredientBatchCardView(viewModel: batchViewModel)
//                    }
//                }
//             }
//             .padding()
//        }
//    }
// }
