import SwiftUI

/**
 Represents a picker component with which a user can pick multiple selections in a set of options.
 */
struct MultiselectPicker<SelectionValue: StringProtocol & Hashable>: View {
    /// The currently selected options.
    @Binding private var selections: Set<SelectionValue>
    /// The available options for the user to select.
    private let options: Set<SelectionValue>
    /// The name of the collection of options.
    private let collectionName: String

    init(_ collectionName: String, selections: Binding<Set<SelectionValue>>, options: Set<SelectionValue>) {
        self.collectionName = collectionName
        self._selections = selections
        self.options = options
    }

    var body: some View {
        Menu {
            ForEach(options.sorted(), id: \.self) { option in
                Button(action: {
                    if selections.contains(option) {
                        selections.remove(option)
                    } else {
                        selections.insert(option)
                    }
                }) {
                    HStack {
                        Text(option)

                        if selections.contains(option) {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Text("\(collectionName): \(selections.isEmpty ? "All" : selections.sorted().joined(separator: ", "))")
                .lineLimit(1)
        }
    }
}
