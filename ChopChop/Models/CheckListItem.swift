import Foundation

struct CheckListItem<T>: Identifiable {
    let id = UUID()
    let item: T
    let displayName: String
    var isChecked = false
}
