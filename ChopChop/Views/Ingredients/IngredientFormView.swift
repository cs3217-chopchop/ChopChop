import SwiftUI

/**
 Represents a view for the form for adding or editing an ingredient.
 */
struct IngredientFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: IngredientFormViewModel

    var body: some View {
        Form {
            if !viewModel.isEdit {
                quantityTypeSection
            }
            nameSection
            categorySection
            imageSection
            saveButton
        }
        .sheet(isPresented: $viewModel.isShowingPhotoLibrary) {
            ImagePicker(sourceType: viewModel.pickerSourceType, selectedImage: $viewModel.image)
        }
        .alert(item: $viewModel.alertIdentifier, content: handleAlert)
    }

    private var quantityTypeSection: some View {
        Section(header: Text("QUANTITY TYPE")) {
            HStack {
                Text(viewModel.quantityType.description)
                Spacer()
                Picker("Quantity Type", selection: $viewModel.quantityType) {
                    ForEach(QuantityType.allCases, id: \.self) {
                        Text($0.description)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
        }
    }

    private var nameSection: some View {
        Section(header: Text("NAME")) {
            TextField("Name", text: $viewModel.name)
        }
    }

    private var categorySection: some View {
        Section(header: Text("CATEGORY")) {
            HStack {
                Text(viewModel.category?.name ?? "Uncategorised")
                Spacer()
                Picker(
                    selection: $viewModel.category,
                    label: Image(systemName: "tag.circle")) {
                    Text("Uncategorised").tag(nil as IngredientCategory?)
                    ForEach(viewModel.categories, id: \.id) {
                        Text($0.name).tag($0 as IngredientCategory?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
        }
    }

    @ViewBuilder
    private var imageSection: some View {
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

    private var saveButton: some View {
        Button("Save") {
            do {
                try viewModel.save()
                presentationMode.wrappedValue.dismiss()
            } catch IngredientError.invalidName {
                viewModel.setAlertState(.emptyName)
            } catch StorageError.saveImageFailure {
                viewModel.setAlertState(.saveImageError)
            } catch {
                viewModel.setAlertState(.saveError)
            }
        }
    }

    private func handleAlert(_ alert: IngredientFormViewModel.AlertIdentifier) -> Alert {
        switch alert.id {
        case .emptyName:
            return Alert(
                title: Text("Invalid name"),
                message: Text("Ingredient name cannot be empty"),
                dismissButton: .default(Text("OK")))
        case .saveImageError:
            return Alert(
                title: Text("Image error"),
                message: Text("An error occurred with saving the image"),
                dismissButton: .default(Text("OK")))
        case .saveError:
            return Alert(
                title: Text("Save error"),
                message: Text("An error occurred with saving the ingredient"),
                dismissButton: .default(Text("OK")))
        }
    }
}
