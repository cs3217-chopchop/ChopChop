import SwiftUI

struct MultiselectPicker<SelectionValue: StringProtocol & Hashable>: View {
    @Binding private var selections: Set<SelectionValue>
    private let options: Set<SelectionValue>
    private let title: String

    init(_ title: String, selections: Binding<Set<SelectionValue>>, options: Set<SelectionValue>) {
        self.title = title
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
            Text("\(title): \(selections.isEmpty ? "All" : selections.sorted().joined(separator: ", "))")
                .lineLimit(1)
        }
    }
}
