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
                if viewModel.image == UIImage() {
                    defaultRecipeBanner
                } else {
                    recipeBanner
                }

                recipeDetails
            }
        }
        .background(
            NavigationLink(
                destination: RecipeFormView(
                    viewModel: RecipeFormViewModel(
                        recipe: viewModel.recipe
                    )
                ),
                isActive: $viewModel.isShowingForm
            ) {
                EmptyView()
            }
        )
        .navigationTitle(viewModel.recipeName)
        .toolbar {
            Button("Edit Recipe") {
                viewModel.isShowingForm = true
            }
        }
        .onAppear {
            viewModel.isShowingForm = false
        }
    }

    var recipeDetails: some View {
        VStack {
            Text("Serves \(viewModel.serving)")
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

    var defaultRecipeBanner: some View {
        Image("recipe")
            .resizable()
            .scaledToFill()
            .frame(height: 300)
            .clipped()
            .overlay(
                Rectangle()
                    .foregroundColor(.clear)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .clear, .black]),
                            startPoint: .top,
                            endPoint: .bottom))
            )
    }

    var recipeBanner: some View {
        Image(uiImage: viewModel.image)
                .resizable()
                .scaledToFill()
                .frame(height: 300)
                .clipped()
                .overlay(
                    Rectangle()
                        .foregroundColor(.clear)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .clear, .black]),
                                startPoint: .top,
                                endPoint: .bottom))
                )
    }
}

struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeView(viewModel: RecipeViewModel(id: 43))
    }
}
