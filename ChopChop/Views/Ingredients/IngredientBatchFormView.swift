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
        .alert(item: $viewModel.alertIdentifier, content: handleAlert)
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
                switch viewModel.ingredientViewModel.ingredient.quantityType {
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
        Button("Save") {
            do {
                try viewModel.save()
                presentationMode.wrappedValue.dismiss()
            } catch QuantityError.invalidQuantity {
                viewModel.setAlertState(.invalidQuantity)
            } catch QuantityError.negativeQuantity {
                viewModel.setAlertState(.negativeQuantity)
            } catch QuantityError.invalidUnit {
                viewModel.setAlertState(.invalidQuantityUnit)
            } catch QuantityError.incompatibleTypes {
                viewModel.setAlertState(.incompatibleQuantityTypes)
            } catch {
                viewModel.setAlertState(.saveError)
            }
        }
    }

    func handleAlert(_ alert: IngredientBatchFormViewModel.AlertIdentifier) -> Alert {
        switch alert.id {
        case .invalidQuantity:
            return Alert(
                title: Text("Invalid quantity"),
                message: Text("Quantity must be a decimal number"),
                dismissButton: .default(Text("OK")))
        case .negativeQuantity:
            return Alert(
                title: Text("Negative quantity"),
                message: Text("Quantity must be non negative"),
                dismissButton: .default(Text("OK")))
        case .invalidQuantityUnit:
            return Alert(
                title: Text("Invalid unit"),
                dismissButton: .default(Text("OK")))
        case .incompatibleQuantityTypes:
            return Alert(
                title: Text("Invalid type"),
                message: Text("Quantity type must match ingredient type"),
                dismissButton: .default(Text("OK")))
        case .saveError:
            return Alert(
                title: Text("Save error"),
                message: Text("An error occurred with saving the batch"),
                dismissButton: .default(Text("OK")))
        }
    }
}
