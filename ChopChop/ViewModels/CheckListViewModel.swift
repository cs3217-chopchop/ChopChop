import SwiftUI

class CheckListViewModel<T>: ObservableObject {
    @Published var checkList: [CheckListItem<T>]

    init(checkList: [CheckListItem<T>]) {
        self.checkList = checkList
    }

    func toggleItem(itemId: UUID) {
        guard let matchedIndex = self.checkList.firstIndex(where: {
            $0.id == itemId
        }) else {
            return
        }
        self.checkList[matchedIndex].isChecked.toggle()
    }
}
