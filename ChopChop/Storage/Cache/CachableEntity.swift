import Foundation

/**
 Represents an entity that can be stored in Cache.
 Entities that are stored in Cache need to conform to Cachable Entity.
 */
protocol CachableEntity {
    var updatedAt: Date { get }
}
