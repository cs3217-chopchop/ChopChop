protocol Node: Hashable {
    associatedtype T: Hashable

    var label: T { get }
}
