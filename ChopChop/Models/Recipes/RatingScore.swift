import FirebaseFirestoreSwift

enum RatingScore: Int {
    case poor = 1, fair, adequate, great, excellent
}

extension RatingScore: CustomStringConvertible {
    var description: String {
        switch self {
        case .poor:
            return "Poor"
        case .fair:
            return "Fair"
        case .adequate:
            return "Adequate"
        case .great:
            return "Great"
        case .excellent:
            return "Excellent"
        }
    }
}

extension RatingScore: Codable {
}
