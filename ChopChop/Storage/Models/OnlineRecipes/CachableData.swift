import Foundation

/**
 Represents a Data that conforms to CachableEntity to allow for caching of images.
 */
struct CachableData: CachableEntity {
    /// The time where the Data is last updated.
    let updatedAt: Date
    /// The Data to be cached.
    let data: Data
}
