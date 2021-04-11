import SwiftUI
import Combine

struct RecipeFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: RecipeFormViewModel

    var body: some View {
        Form {
            generalSection
            imageSection
            ingredientsSection
            stepsSection
            actionButton
        }
        .alert(isPresented: $viewModel.alertIsPresented) {
            Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage))
        }
        .navigationTitle("\(viewModel.isEditing ? "Edit" : "Add") Recipe")
        .sheet(isPresented: $viewModel.imagePickerIsPresented) {
            ImagePicker(sourceType: viewModel.pickerSourceType, selectedImage: $viewModel.image)
        }
    }

    @ViewBuilder
    var generalSection: some View {
        nameField
        servingsField
        categoryField
        difficultyField
    }

    var nameField: some View {
        Section(header: Text("Name")) {
            TextField("Name", text: $viewModel.name)
        }
    }

    var servingsField: some View {
        Section(header: Text("Serving size")) {
            TextField("Serving size", text: Binding(get: { viewModel.servings },
                                                    set: viewModel.setServings))
                .keyboardType(.numberPad)
        }
    }

    var categoryField: some View {
        Section(header: Text("Category")) {
            Picker(viewModel.category?.name ?? "Uncategorised", selection: $viewModel.category) {
                Text("Uncategorised").tag(nil as RecipeCategory?)
                ForEach(viewModel.categories) {
                    Text($0.name).tag($0 as RecipeCategory?)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }

    var difficultyField: some View {
        Section(header: Text("Difficulty")) {
            Picker(viewModel.difficulty?.description ?? "None", selection: $viewModel.difficulty) {
                Text("None").tag(nil as Difficulty?)
                ForEach(Difficulty.allCases, id: \.self) {
                    Text($0.description).tag($0 as Difficulty?)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }

    var imageSection: some View {
       Section(header: Text("Image")) {
           if viewModel.image != UIImage() {
               Image(uiImage: viewModel.image)
                   .resizable()
                   .scaledToFill()
                   .frame(height: 300)
           }
           HStack {
               Button("Upload Image") {
                   viewModel.pickerSourceType = .photoLibrary
                   viewModel.imagePickerIsPresented = true
               }
               .buttonStyle(BorderlessButtonStyle())
               Spacer()
               Button("Take Photo") {
                   viewModel.pickerSourceType = .camera
                   viewModel.imagePickerIsPresented = true
               }
               .buttonStyle(BorderlessButtonStyle())
           }
       }
    }

    var ingredientsSection: some View {
        Section(header: Text("Ingredients")) {
            ForEach(viewModel.ingredients, id: \.self) { ingredientRowViewModel in
                HStack {
                    RecipeIngredientRowView(viewModel: ingredientRowViewModel)
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .onTapGesture {
                            viewModel.ingredients.removeAll(where: { $0 === ingredientRowViewModel })
                        }
                }
            }

            if viewModel.isParsingIngredients {
                TextEditor(text: $viewModel.ingredientsToBeParsed)
                Button("Add ingredients", action: viewModel.parseIngredients)
            } else {
                Button("Add ingredient") {
                    viewModel.ingredients.append(RecipeIngredientRowViewModel())
                }
                Button("Parse ingredients") {
                    viewModel.isParsingIngredients = true
                }
            }
        }
    }

    var stepsSection: some View {
        Section(header: Text("Steps")) {
            NavigationLink("Edit steps",
                           destination: EditorGraphView(viewModel: EditorGraphViewModel(graph: viewModel.stepGraph)),
                           isActive: $viewModel.stepGraphIsPresented)

            if viewModel.isParsingSteps {
                TextEditor(text: $viewModel.stepsToBeParsed)
                Button("Replace steps", action: viewModel.parseSteps)
            } else {
                Button("Parse steps") {
                    viewModel.isParsingSteps = true
                }
            }
        }
    }

    var actionButton: some View {
        Section {
            Button(viewModel.isEditing ? "Save Recipe" : "Add Recipe") {
                if viewModel.saveRecipe() {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct RecipeFormView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeFormView(viewModel: RecipeFormViewModel())
    }
}
