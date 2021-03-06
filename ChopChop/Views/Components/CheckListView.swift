import SwiftUI

/**
 Represents a view of a check list of items.
 */
struct CheckListView<T>: View {
    @StateObject var viewModel: CheckListViewModel<T>

    var body: some View {
        List {
            ForEach(viewModel.checkList) { item in
                HStack {
                    Text(item.displayName)
                    Spacer()
                    item.isChecked ? Image(systemName: "checkmark.square") : Image(systemName: "square")
                }
                .onTapGesture {
                    viewModel.toggleItem(itemId: item.id)
                }
            }
        }
    }
}

struct CheckListView_Previews: PreviewProvider {
    static var previews: some View {
        CheckListView(viewModel: CheckListViewModel<Any>(checkList: []))
    }
}
