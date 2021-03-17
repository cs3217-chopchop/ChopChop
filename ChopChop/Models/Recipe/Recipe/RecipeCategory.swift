class RecipeCategory {
    var id: Int64?
    private(set) var name: String

    init(name: String) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw RecipeCategoryError.invalidName
        }
        self.name = trimmedName
    }

    func updateName(_ name: String) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw RecipeCategoryError.invalidName
        }
        self.name = trimmedName
    }
    
}

enum RecipeCategoryError: Error {
    case invalidName
}
