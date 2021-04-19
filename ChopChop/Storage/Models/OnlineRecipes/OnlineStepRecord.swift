import Foundation
import FirebaseFirestoreSwift

struct OnlineStepRecord {
    var id: String
    var content: String
}

extension OnlineStepRecord: Codable {
}

extension OnlineStepRecord: Equatable {
}

extension OnlineStepRecord {
    var asDict: [String: Any] {
        ["id": id, "content": content]
    }
}
