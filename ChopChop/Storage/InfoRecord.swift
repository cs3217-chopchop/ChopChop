import Foundation

protocol InfoRecord: Codable {
    var id: String? { get set }
    var updatedAt: Date? { get set }
}
