struct Node<T: Hashable & Codable>: Hashable, Codable {
    var label: T

    init(_ label: T) {
        self.label = label
    }
}
