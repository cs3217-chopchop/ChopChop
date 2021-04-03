import Foundation

protocol Node: Hashable, Identifiable {
    associatedtype T: Hashable

    var id: UUID { get }
    var label: T { get }
}
