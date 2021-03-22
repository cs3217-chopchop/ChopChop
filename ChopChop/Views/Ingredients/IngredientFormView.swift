import SwiftUI

struct IngredientFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: IngredientFormViewModel

    var body: some View {
        Form {
            if !viewModel.isEdit {
                quantityTypeSection
            }
            nameSection
            imageSection
            saveButton
        }
        .sheet(isPresented: $viewModel.isShowingPhotoLibrary) {
            ImagePicker(sourceType: viewModel.pickerSourceType, selectedImage: $viewModel.image)
        }
    }

    var quantityTypeSection: some View {
        Section(header: Text("QUANTITY TYPE")) {
            HStack {
                Text(viewModel.selectedType.description)
                Spacer()
                Picker("Quantity Type", selection: $viewModel.selectedType) {
                    ForEach(BaseQuantityType.allCases, id: \.self) {
                        Text($0.description)
                    }
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }

    var nameSection: some View {
        Section(header: Text("NAME")) {
            TextField("Name", text: $viewModel.inputName)
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

    var saveButton: some View {
        Button("Save") {
            defer {
                presentationMode.wrappedValue.dismiss()
            }

            do {
                try viewModel.save()
            } catch {
                return
            }
        }
    }
}

struct IngredientFormView_Previews: PreviewProvider {
    // swiftlint:disable force_try
    static var previews: some View {
        IngredientFormView(
            viewModel: IngredientFormViewModel(
                edit: try! Ingredient(name: "Apple", type: .count)))
    }
}
