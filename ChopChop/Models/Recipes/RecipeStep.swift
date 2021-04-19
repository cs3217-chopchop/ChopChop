import Foundation
import GRDB

/**
 Represents a step in the instructions required to make a recipe.
 
 Representation Invariants:
 - Content is not empty.
 - Timers are positive.
 */
struct RecipeStep: Hashable {
    // MARK: - Specification Fields
    /// The content of the step. Cannot be empty.
    let content: String
    /// The time durations described in the step.
    let timers: [TimeInterval]

    var timeTaken: TimeInterval {
        timers.isEmpty ? TimeInterval(RecipeStepParser.parseTotalDuration(step: content)) : timers.reduce(0, +)
    }

    /**
     Instantiates a recipe step with the given content and timers.

     - Throws:
        - `RecipeStepError.invalidContent` if the given content trimmed is empty.
        - `RecipeStepError.invalidDuration` if any given timer is non positive.
     */
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
