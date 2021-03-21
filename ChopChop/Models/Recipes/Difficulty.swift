import GRDB

/// Equivalent to 5 stars normally seen in recipes
enum Difficulty: Int, DatabaseValueConvertible, Codable {
    case veryEasy
    case easy
    case medium
    case hard
    case veryHard
}
