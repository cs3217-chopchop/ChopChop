import SwiftUI

struct IngredientBatchFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: IngredientBatchFormViewModel

    var body: some View {
        Form {
            quantitySection
            expiryDateSection
            saveButton
        }
    }

    @ViewBuilder
    var quantitySection: some View {
        Section(header: Text("QUANTITY")) {
            HStack {
                TextField("Quantity", text: $viewModel.inputQuantity)
                    .keyboardType(.numberPad)
                    .frame(width: 100)
                Text(viewModel.selectedUnit)
                Spacer()
                switch viewModel.ingredient.quantityType {
                case .count:
                    EmptyView()
                case .mass:
                    Picker("Unit", selection: $viewModel.selectedUnit) {
                        ForEach(viewModel.massUnits, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                case .volume:
                    Picker("Unit", selection: $viewModel.selectedUnit) {
                        ForEach(viewModel.volumeUnits, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
        }
    }

    var expiryDateSection: some View {
        Section(header: Text("EXPIRY DATE")) {
            Toggle(isOn: $viewModel.expiryDateEnabled) {
                Text("Expires")
            }
            if viewModel.expiryDateEnabled {
                DatePicker(
                    "Expiry Date",
                    selection: $viewModel.selectedDate,
                    displayedComponents: [.date])
            }
        }
    }

    var saveButton: some View {
        Button(action: save) {
            Text("Save")
                .foregroundColor(viewModel.areFieldsValid ? .blue : .gray)
        }
        .disabled(!viewModel.areFieldsValid)
    }

    func save() {
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

struct IngredientBatchEditView_Previews: PreviewProvider {
    // swiftlint:disable force_try
    static var previews: some View {
        IngredientBatchFormView(
            viewModel: IngredientBatchFormViewModel(
                edit: IngredientBatch(
                    quantity: try! Quantity(.count, value: 3),
                    expiryDate: Date().addingTimeInterval(100_000)),
                in: try! Ingredient(
                    name: "Apple",
                    type: .count,
                    batches: [
                        IngredientBatch(
                            quantity: try! Quantity(.count, value: 3),
                            expiryDate: Date()),
                        IngredientBatch(
                            quantity: try! Quantity(.count, value: 3)),
                        IngredientBatch(
                            quantity: try! Quantity(.count, value: 3),
                            expiryDate: Date().addingTimeInterval(100_000)),
                        IngredientBatch(
                            quantity: try! Quantity(.count, value: 3),
                            expiryDate: Date().addingTimeInterval(200_000))
                    ])))
    }
}
