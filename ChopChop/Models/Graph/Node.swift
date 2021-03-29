import CoreGraphics
import Foundation

final class Node: Identifiable, Codable {
    let id: UUID
    var position: CGPoint
    var text: String

    init(position: CGPoint = .zero, text: String = "") {
        self.id = UUID()
        self.position = position
        self.text = text
    }
}

extension Node: Equatable {
    static func == (lhs: Node, rhs: Node) -> Bool {
        lhs.id == rhs.id
    }
}
