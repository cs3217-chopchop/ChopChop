import Foundation

protocol CachableEntity {
    var id: String { get }
    var updatedAt: Date { get }
}
