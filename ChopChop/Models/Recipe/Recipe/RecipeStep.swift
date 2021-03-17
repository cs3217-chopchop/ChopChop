import Foundation

class RecipeStep {
    var id: Int64?
    private(set) var content: String // can be empty

    /// Estimation of time taken in seconds based only on content of recipe step. Future releases may take into account previous user input
    var timeTaken: Int {
        RecipeStepParser.parseTimeTaken(step: content)
    }

    init(content: String) {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        self.content = trimmedContent
    }

    func updateContent(_ content: String) throws {
        self.content = content
    }

}

extension RecipeStep: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = RecipeStep(content: content)
        copy.id = id
        return copy
    }
}
