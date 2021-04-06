import FirebaseFirestoreSwift

struct OnlineStepEdgeRecord {
    var sourceStep: String
    var destinationStep: String
}

extension OnlineStepEdgeRecord: Equatable {
}

extension OnlineStepEdgeRecord: Codable {
}
