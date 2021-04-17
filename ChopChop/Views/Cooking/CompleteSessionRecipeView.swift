import SwiftUI

struct CompleteSessionRecipeView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: CompleteSessionRecipeViewModel
    @Binding var isComplete: Bool

    var body: some View {
        VStack {
            Text("Deduct Ingredients")
                .font(.title)
                .padding()

            if viewModel.deductibleIngredients.isEmpty {
                NotFoundView(entityName: "Deductible Ingredients")
            } else {
                Form {
                    ForEach(viewModel.deductibleIngredients, id: \.self) { deductibleIngredientViewModel in
                        DeductibleIngredientView(viewModel: deductibleIngredientViewModel)
                    }
                }
            }

            Button("Complete Recipe") {
                if viewModel.deductibleIngredients.isEmpty || viewModel.completeRecipe() {
                    presentationMode.wrappedValue.dismiss()
                    isComplete = true
                }
            }
        }
        .padding()
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}

struct CompleteSessionView_Previews: PreviewProvider {
    static var previews: some View {
        if let recipe = try? Recipe(name: "Preview") {
            CompleteSessionRecipeView(viewModel: CompleteSessionRecipeViewModel(recipe: recipe),
                                      isComplete: .constant(false))
        }
    }
}
