import Foundation

// Used for Image
struct CachableData: CachableEntity {
    var id: String
    var updatedAt: Date
    let data: Data
}
