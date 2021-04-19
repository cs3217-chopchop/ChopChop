import FirebaseFirestoreSwift

/**
 Represents the different rating scores that can be given to a recipe.
 */
enum RatingScore: Int {
    case poor = 1, fair, adequate, great, excellent
}

// MARK: CustomStringConvertible
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

// MARK: Codable - Allows encoding to and decoding from firebase document fields
extension RatingScore: Codable {
}

// MARK: CaseIterable
extension RatingScore: CaseIterable {
    static var max: Int {
        RatingScore.allCases.map { $0.rawValue }.max() ?? 0
    }
}
