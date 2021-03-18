class RecipeCategory: Identifiable, Hashable {
    var id: Int64?
    private(set) var name: String

    init(id: Int64?, name: String) throws {
        self.id = id
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw RecipeCategoryError.invalidName
        }
        self.name = trimmedName
    }

    func rename(_ name: String) throws {
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
