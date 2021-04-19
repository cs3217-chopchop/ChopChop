import Foundation

/**
 Represents a Data that conforms to CachableEntity to allow for caching of images.
 */
struct CachableData: CachableEntity {
    // MARK: - Specification Fields
    /// Identifies a unique Data for caching.
    var id: String
    /// The time where the Data is last updated.
    var updatedAt: Date
    /// The Data to be cached.
    let data: Data
}
