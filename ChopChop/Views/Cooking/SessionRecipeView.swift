import SwiftUI

struct SessionRecipeView: View {
    @ObservedObject var viewModel: SessionRecipeViewModel

    var body: some View {
        ScrollView {
            ZStack(alignment: .bottomLeading) {
                Image(uiImage: viewModel.image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 300)
                    .clipped()
                    .overlay(
                        Rectangle()
                            .foregroundColor(.clear)
                            .background(LinearGradient(gradient:
                                                        Gradient(colors: [.clear, .clear, .black]), startPoint: .top, endPoint: .bottom))
                    )
                Text(viewModel.name)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
            }
            Text("Details")
                .font(.title2)
                .bold()
            Text("""
                Serves \(viewModel.servings.removeZerosFromEnd()) \(viewModel.servings == 1 ? "person" : "people")
                """)
            HStack(spacing: 0) {
                Text("Difficulty: ")
                DifficultyView(difficulty: viewModel.difficulty)
            }
            Text(viewModel.recipeCategory)
            Text("Time taken: \(viewModel.totalTimeTaken)")

            VStack(alignment: .leading) {
                ingredients
                steps
            }
            Spacer()
            Button(action: {
                viewModel.toggleShowComplete()
            }) {
                Text("  ✔ Complete cooking  ")
                    .foregroundColor(viewModel.completeSessionRecipeViewModel.isSuccess ? .gray : .black)
                    .background(viewModel.completeSessionRecipeViewModel.isSuccess ? Color.white : Color.green)
                    .font(.title2)
                    .clipShape(Capsule())
                    .padding()
            }.disabled(viewModel.completeSessionRecipeViewModel.isSuccess)
        }
        // https://stackoverflow.com/questions/57103800/swiftui-support-multiple-modals
        .background(EmptyView().sheet(isPresented: $viewModel.isShowComplete) {
            CompleteSessionRecipeView(viewModel: viewModel.completeSessionRecipeViewModel)
        })
    }

    var ingredients: some View {
        VStack(alignment: .center) {
            Text("Ingredients")
                .font(.title2)
                .bold()
            ForEach(viewModel.ingredients, id: \.name) { ingredient in
                Text(ingredient.description)
            }
        }.padding()
    }

    var steps: some View {
        VStack {
            VStack(alignment: .center) {
                Text("Steps")
                    .font(.title2)
                    .bold()
            }
            VStack(alignment: .leading) {
                ForEach(viewModel.steps) { step in
                    SessionRecipeStepView(viewModel: step)
                }
            }
        }.padding()
    }
}

struct SessionRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        SessionRecipeView(viewModel: SessionRecipeViewModel(recipeInfo:
                                                                RecipeInfo(id: 5, name: "Pancakes", servings: 5, difficulty: Difficulty.easy)))
    }
}
