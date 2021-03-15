import Foundation

class RecipeStep {
    let id: Int64
    var content: String
    var timeTaken: Int {
        RecipeStepParser.parseTimeTaken(step: content)
    } // nth to do with timer. only depedendent on whats in the content and prev user input

    init(id: Int64, content: String) {
        self.id = id
        self.content = content
        assert(checkRepresentation())
    }

    func updateContent(content: String) {
        self.content = content
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
