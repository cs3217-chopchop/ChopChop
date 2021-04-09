import GRDB

enum Difficulty: Int, Codable, CaseIterable, DatabaseValueConvertible {
    case veryEasy = 1
    case easy
    case medium
    case hard
    case veryHard
}

// MARK: - CustomStringConvertible
extension Difficulty: CustomStringConvertible {
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
