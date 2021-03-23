//
//  RecipeView.swift
//  ChopChop
//
//  Created by Cao Wenjie on 21/3/21.
//

import SwiftUI

struct RecipeView: View {
    @ObservedObject var viewModel: RecipeViewModel
    var body: some View {
        ScrollView {
            VStack {
                Image("recipe")
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .cornerRadius(10)
                    .clipped()
                Text("""
                    Serves \(viewModel.serving)
                    """)
                Text(viewModel.difficulty?.description ?? "")
                Text(viewModel.recipeCategory)
                Spacer()
                ForEach(viewModel.ingredients, id: \.self) { ingredient in
                    Text(ingredient.description)
                }
                Spacer()
                ForEach(0..<viewModel.steps.count, id: \.self) { idx in
                    Text("Step \(idx + 1): \(viewModel.steps[idx])")
                }
            }
        }
        .navigationTitle(viewModel.recipeName)
        .toolbar {
            NavigationLink(
                destination: RecipeFormView(
                    viewModel: RecipeFormViewModel(
                        recipe: viewModel.recipe
                    )
                )
            ) {
                Text("Edit Recipe")
            }
        }
//        .onAppear {
////            viewModel.loadRecipe(id: viewModel.recipe.id)
//            print("hi")
//        }
    }
}

struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeView(viewModel: RecipeViewModel(id: 43))
    }
}
