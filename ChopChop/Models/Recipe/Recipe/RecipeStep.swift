import Foundation

class RecipeStep {
    var id: Int64?
    private(set) var content: String // can be empty

    /// Estimation of time taken in seconds based only on content of recipe step.
    /// Future releases may take into account previous user input
    var timeTaken: Int {
        RecipeStepParser.parseTimeTaken(step: content)
    }

    init(content: String) throws {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else {
            throw RecipeStepError.invalidContent
        }
        self.content = trimmedContent
    }

    func updateContent(_ content: String) throws {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else {
            throw RecipeStepError.invalidContent
        }
        self.content = trimmedContent
    }

}

extension RecipeStep: Equatable {
    static func == (lhs: RecipeStep, rhs: RecipeStep) -> Bool {
        lhs.content == rhs.content
    }
}

extension RecipeStep: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        guard let copy = try? RecipeStep(content: content) else {
            fatalError("Cannot copy RecipeStep")
        }
        copy.id = id
        return copy
    }
}

enum RecipeStepError: Error {
    case invalidContent
}