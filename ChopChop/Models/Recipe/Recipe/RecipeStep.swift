class RecipeStep {
    let id: Int64
    var content: String
    var timeTaken: Double {
        RecipeStepParser().parseTimeTaken(step: content)
    } // nth to do with timer. only depedendent on whats in the content and prev user input

    init(id: Int64, content: String, timeTaken: Double) {
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
