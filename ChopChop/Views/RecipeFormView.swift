//
//  RecipeFormView.swift
//  ChopChop
//
//  Created by Cao Wenjie on 20/3/21.
//

import SwiftUI
import Combine

struct RecipeFormView: View {

    @ObservedObject var viewModel: RecipeFormViewModel

    var body: some View {
        Form {
            Section(header: Text("General Details")) {
                TextField("Recipe name", text: $viewModel.recipeName)
                TextField("Serving size", text: $viewModel.serving)
                Picker("Cuisine", selection: $viewModel.recipeCategory) {
                    ForEach(viewModel.existingRecipeCategories, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                difficulty
            }

            Section(header: Text("Ingredient List")) {
                ingredients
                addIngredientButton
            }

            Section(header: Text("Instructions")) {
                steps
                addStepButton
            }

            Section(header: Text("Quick Parse")) {
                TextEditor(text: $viewModel.instructionParsingString)
                    .disableAutocorrection(true)
                TextEditor(text: $viewModel.ingredientParsingString)
                    .disableAutocorrection(true)
                Button(
                    action: {
                        viewModel.parseData()
                    },
                    label: {
                        Text("Parse data")
                    }
                )
            }

            Button("Add Recipe") {
//                try viewModel.saveRecipe()
            }
        }
    }

    var difficulty: some View {
        HStack {
            Picker("Difficulty", selection: $viewModel.difficulty) {
                ForEach(Difficulty.allCases, id: \.self) {
                    Text($0.description)
                }
            }
            Spacer()
            Text(viewModel.difficulty.description)
        }
        .pickerStyle(MenuPickerStyle())
    }

    var addIngredientButton: some View {
        Button("Add new ingredient") {
            let newIngredient = RecipeIngredientRowViewModel()
            viewModel.ingredients.append(newIngredient)
        }
    }

    var ingredients: some View {
        List {
            ForEach(0..<viewModel.ingredients.count, id: \.self) { index in
                HStack {
                    RecipeIngredientRowView(viewModel: viewModel.ingredients[index])
                    Button("Delete") {
                        viewModel.ingredients.remove(at: index)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
        }
    }

    var addStepButton: some View {
        Button("Add new step") {
            viewModel.steps.append("")
        }
    }

    var steps: some View {
        List {
            ForEach(0..<viewModel.steps.count, id: \.self) { index in
                HStack {
                    Text("Step \(index + 1)")
                    TextField("Description", text: $viewModel.steps[index])
                    Button("Delete") {
                        viewModel.steps.remove(at: index)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            .onMove(perform: moveSteps)
        }
    }

    private func moveSteps(source: IndexSet, destination: Int) {
        viewModel.steps.move(fromOffsets: source, toOffset: destination)
    }

}

struct RecipeFormView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeFormView(viewModel: RecipeFormViewModel())
    }
}
