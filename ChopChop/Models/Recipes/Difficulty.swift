import GRDB

/// Equivalent to 5 stars normally seen in recipes
enum Difficulty: Int, Codable, CaseIterable, DatabaseValueConvertible {
    case veryEasy = 1
    case easy
    case medium
    case hard
    case veryHard

    init(description: String) throws {
        switch description {
        case Difficulty.veryEasy.description:
            self = .veryEasy
        case Difficulty.easy.description:
            self = .easy
        case Difficulty.medium.description:
            self = .medium
        case Difficulty.hard.description:
            self = .hard
        case Difficulty.veryHard.description:
            self = .veryHard
        default:
            throw DifficultyError.invalidDifficulty
        }
    }
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

enum DifficultyError: Error {
    case invalidDifficulty
}
