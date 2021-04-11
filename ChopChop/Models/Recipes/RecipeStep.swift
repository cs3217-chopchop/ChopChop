import Foundation

struct RecipeStep: Hashable {
    let content: String
    var timeTaken: Int {
        RecipeStepParser.parseTimeTaken(step: content)
    }

    init(_ content: String) throws {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else {
            throw RecipeStepError.invalidContent
        }

        self.content = trimmedContent
    }
}

enum RecipeStepError: LocalizedError {
    case invalidContent

    var errorDescription: String? {
        switch self {
        case .invalidContent:
            return "Recipe step should not be empty."
        }
    }
}
