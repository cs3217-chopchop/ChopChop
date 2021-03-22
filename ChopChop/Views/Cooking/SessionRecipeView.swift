import SwiftUI

struct SessionRecipeView: View {
    @ObservedObject var viewModel: SessionRecipeViewModel

    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    ZStack(alignment: .bottomLeading) {
                        Image("")
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
                    Text("Servings: \(viewModel.servings, specifier: "%.2f")")
                    Text("Difficulty: \(viewModel.difficulty) / 5")
        //            Text("Time Taken: \(viewModel.difficulty) / 5")
                    Text("Ingredients")
                    Text("Steps")
                    ForEach(viewModel.steps, id: \.step.content) { step in
                        // TODO remove id as step.content
                        SessionRecipeStepView(viewModel: SessionRecipeStepViewModel(sessionRecipeStep: step))
                    }
                }
            }
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
}

struct SessionRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable force_try line_length
        SessionRecipeView(viewModel: SessionRecipeViewModel(sessionRecipe: SessionRecipe(recipe: try! Recipe(name: "Pancakes", servings: 5, difficulty: Difficulty.medium, steps: [try! RecipeStep(content: "In a large bowl, mix dry ingredients together until well-blended."),
                                                                                                                                                                              try! RecipeStep(content: "Add milk and mix well until smooth.") ,
                                                                                                                                                                              try! RecipeStep(content: """
                                                                                                                                                                              Separate the egg, placing the whites in a medium bowl and the yolks in the batter. Mix \
                                                                                                                                                                              well.
                                                                                                                                                                              """) ,
                                                                                                                                                                              try! RecipeStep(content: "Beat whites until stiff and then fold into batter gently") ,
                                                                                                                                                                              try! RecipeStep(content: "Pour ladles of the mixture into a non-stick pan, one at a time."),
                                                                                                                                                                              try! RecipeStep(content: """
                                                                                                                                                                              Cook for 30s until the edges are dry and bubbles appear on surface. Flip; cook for 1 to 2 minutes. \
                                                                                                                                                                              Yields 12 to 14 pancakes.
                                                                                                                                                                              """)], ingredients: []))))
    }
}
