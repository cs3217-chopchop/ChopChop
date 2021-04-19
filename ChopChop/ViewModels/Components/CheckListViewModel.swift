import SwiftUI

/**
 Represents a view model for a view of a check list of items.
 */
class CheckListViewModel<T>: ObservableObject {
    /// The check list of items.
    @Published var checkList: [CheckListItem<T>]

    init(checkList: [CheckListItem<T>]) {
        self.checkList = checkList
    }

    /**
     Toggles the checked property of the item with the given id.
     If such an item does not exist in the check list, do nothing.
     */
    func toggleItem(itemId: UUID) {
        guard let matchedIndex = self.checkList.firstIndex(where: {
            $0.id == itemId
        }) else {
            return
        }
        self.checkList[matchedIndex].isChecked.toggle()
    }
}
