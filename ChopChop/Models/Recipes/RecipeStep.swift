import Foundation

struct RecipeStep: Hashable {
    let content: String
    let timers: [TimeInterval]
    var timeTaken: Int {
        RecipeStepParser.parseTimeTaken(step: content)
    }

    init(_ content: String, timers: [TimeInterval] = []) throws {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedContent.isEmpty else {
            throw RecipeStepError.invalidContent
        }

        guard timers.allSatisfy({ $0 > 0 }) else {
            throw RecipeStepError.invalidDuration
        }

        self.content = trimmedContent
        self.timers = timers
    }
}

enum RecipeStepError: LocalizedError {
    case invalidContent, invalidDuration

    var errorDescription: String? {
        switch self {
        case .invalidContent:
            return "Recipe step should not be empty."
        case .invalidDuration:
            return "Recipe step timer duration should be positive."
        }
    }
}
