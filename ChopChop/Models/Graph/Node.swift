import CoreGraphics
import Foundation

struct Node: Identifiable, Codable, Equatable {
    private(set) var id = UUID()
    var position: CGPoint
    var text: String
}
