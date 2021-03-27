import CoreGraphics
import Foundation

final class Node: Identifiable, Codable, Equatable {
    static func == (lhs: Node, rhs: Node) -> Bool {
        lhs.id == rhs.id
    }

    private(set) var id = UUID()
    var position: CGPoint
    var text: String

    init(position: CGPoint, text: String) {
        self.position = position
        self.text = text
    }
}
