import SwiftUI

struct OnlineRecipeCollectionView: View {
    @ObservedObject var viewModel: OnlineRecipeCollectionViewModel

    var body: some View {
        ScrollView {
            
            Text(viewModel.filter.rawValue)


            if viewModel.filter == OnlineRecipeFilter.own {
                ForEach(viewModel.recipes) { recipe in
                    OnlineRecipeBySelfView(viewModel: OnlineRecipeBySelfViewModel(recipe: recipe))
                }
            } else {
                ForEach(viewModel.recipes) { recipe in
                    OnlineRecipeByUserView(viewModel: OnlineRecipeByUserViewModel(recipe: recipe))
                }
            }
        }.toolbar {
            HStack {
                Text("Recipe Feed:")
                Picker("Filter by", selection: $viewModel.filter) {
                    ForEach(OnlineRecipeFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
            }
        }
    }
}

struct OnlineRecipeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        OnlineRecipeCollectionView(viewModel: OnlineRecipeCollectionViewModel())
    }
}
