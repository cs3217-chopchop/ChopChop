import Foundation
import FirebaseFirestoreSwift

struct OnlineStepEdgeRecord {
    var sourceStepId: String
    var destinationStepId: String
}

extension OnlineStepEdgeRecord: Equatable {
}

extension OnlineStepEdgeRecord: Codable {
}

extension OnlineStepEdgeRecord {
    var asDict: [String: Any] {
        ["sourceStepId": sourceStepId, "destinationStepId": destinationStepId]
    }
}
