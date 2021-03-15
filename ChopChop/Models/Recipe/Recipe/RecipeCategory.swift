class RecipeCategory {
    let id: Int64
    private(set) var name: String

    init(id: Int64, name: String) {
        self.id = id
        self.name = name
        assert(checkRepresentation())
    }

    func updateName(name: String) throws {
        assert(checkRepresentation())
        guard name != "" else {
            throw RecipeCategoryError.invalidName
        }
        self.name = name
        assert(checkRepresentation())
    }

    private func checkRepresentation() -> Bool {
        name != ""
    }
    
}
