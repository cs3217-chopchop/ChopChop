import Foundation

class RecipeStep {
    let id: Int64
    private(set) var content: String

    /// Estimation of time taken based only on content of recipe step. Future releases may take into account previous user input
    var timeTaken: Int {
        RecipeStepParser.parseTimeTaken(step: content)
    }

    init(id: Int64, content: String) {
        self.id = id
        self.content = content
        assert(checkRepresentation())
    }

    func updateContent(content: String) throws {
        assert(checkRepresentation())
        guard content != "" else {
            throw RecipeStepError.invalidName
        }
        self.content = content
        assert(checkRepresentation())
    }


    private func checkRepresentation() -> Bool {
        content != ""
    }

}

extension RecipeStep: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = RecipeStep(id: id, content: content)
        return copy
    }
}
