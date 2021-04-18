import Foundation

/**
 Represents a node in a graph, uniquely identified by its label.
 */
protocol Node: Hashable, Identifiable {
    associatedtype T: Hashable

    var id: UUID { get }

    // MARK: - Specification Fields
    /// The label associated with the node, which uniquely identifies it.
    var label: T { get }
}
