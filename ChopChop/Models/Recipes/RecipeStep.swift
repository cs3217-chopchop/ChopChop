import Foundation

struct RecipeStep: Hashable {
    let content: String
    var timers: [TimeInterval]
    var timeTaken: Int {
        RecipeStepParser.parseTimeTaken(step: content)
    }

    init(_ content: String, timers: [TimeInterval] = []) throws {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else {
            throw RecipeStepError.invalidContent
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
            return "Recipe step timer duration not valid."
        }
    }
}
