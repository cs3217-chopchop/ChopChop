import GRDB

/// Equivalent to 5 stars normally seen in recipes
enum Difficulty: Int, Codable, CaseIterable, DatabaseValueConvertible {
    case veryEasy = 1
    case easy
    case medium
    case hard
    case veryHard
}
