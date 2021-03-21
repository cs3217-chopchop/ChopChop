import GRDB

/// Equivalent to 5 stars normally seen in recipes
enum Difficulty: Int, DatabaseValueConvertible, Codable, CaseIterable {
    case veryEasy
    case easy
    case medium
    case hard
    case veryHard
}

// MARK: - CustomStringConvertible
extension Difficulty {
    var description: String {
        switch self {
        case .veryEasy:
            return "Very Easy"
        case .easy:
            return "Easy"
        case .medium:
            return "Medium"
        case .hard:
            return "Hard"
        case .veryHard:
            return "Very Hard"
        }
    }
}
