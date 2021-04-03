//
//  RecipeFormView.swift
//  ChopChop
//
//  Created by Cao Wenjie on 20/3/21.
//

import SwiftUI
import Combine

struct RecipeFormView: View {
    @Environment(\.presentationMode) var mode
    @ObservedObject var viewModel: RecipeFormViewModel

    init(viewModel: RecipeFormViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Form {
            generalSection
            imageSection
            ingredientSection
            instructionSection
            parsingSection
            actionButton
        }
        .alert(isPresented: $viewModel.hasError) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("Ok")))
        }
        .navigationTitle(viewModel.isEdit ? Text("Edit Recipe") : Text("Add Recipe"))
        .sheet(isPresented: $viewModel.isShowingPhotoLibrary) {
            ImagePicker(sourceType: viewModel.pickerSourceType, selectedImage: $viewModel.image)
        }
    }

    var generalSection: some View {
        Section(header: Text("General Details")) {
            TextField("Recipe name", text: $viewModel.recipeName)
            TextField("Serving size", text: $viewModel.serving)
            cuisine
            .pickerStyle(MenuPickerStyle())
            difficulty
        }
    }

    var instructionSection: some View {
        Section(header: Text("Instructions")) {
            addStepButton
        }
    }

    var ingredientSection: some View {
        Section(header: Text("Ingredient List")) {
            ingredients
            addIngredientButton
        }
    }

    var actionButton: some View {
        Button(viewModel.isEdit ? "Save Recipe" : "Add Recipe") {
            if viewModel.saveRecipe() {
                mode.wrappedValue.dismiss()
            }
        }
    }

    var parsingSection: some View {
        Section(header: Text("Quick Parse")) {
            HStack {
                Text("Ingredient")
                TextEditor(text: $viewModel.ingredientParsingString)
                    .disableAutocorrection(true)
            }

            HStack {
                Text("Instructions")
                TextEditor(text: $viewModel.instructionParsingString)
                    .disableAutocorrection(true)
            }

            Button(
                action: {
                    viewModel.parseData()
                },
                label: {
                    Text("Parse data")
                }
            )
        }
    }

    @ViewBuilder
    var imageSection: some View {
       Section(header: Text("IMAGE")) {
           if viewModel.image != UIImage() {
               Image(uiImage: viewModel.image)
                   .resizable()
                   .scaledToFill()
                   .frame(height: 300)
           }
           HStack {
               Button("Upload Image") {
                   viewModel.pickerSourceType = .photoLibrary
                   viewModel.isShowingPhotoLibrary = true
               }
               .buttonStyle(BorderlessButtonStyle())
               Spacer()
               Button("Take Photo") {
                   viewModel.pickerSourceType = .camera
                   viewModel.isShowingPhotoLibrary = true
               }
               .buttonStyle(BorderlessButtonStyle())
           }
       }
    }

    var cuisine: some View {
        HStack {
            Picker("Cuisine", selection: $viewModel.recipeCategory) {
                ForEach(viewModel.allRecipeCategories.map({ $0.name }), id: \.self) {
                    Text($0)
                }
            }
            Spacer()
            Text(viewModel.recipeCategory)
        }
    }

    var difficulty: some View {
        HStack {
            Picker("Difficulty", selection: $viewModel.difficulty) {
                ForEach(Difficulty.allCases.map({ $0.description }), id: \.self) {
                    Text($0)
                }
            }
            Spacer()
            Text(viewModel.difficulty)
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
        NavigationLink(destination: EditorGraphView(viewModel: EditorGraphViewModel(graph: viewModel.stepGraph))) {
            Text("Edit Instructions")
        }
    }
}

struct RecipeFormView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeFormView(viewModel: RecipeFormViewModel())
    }
}
