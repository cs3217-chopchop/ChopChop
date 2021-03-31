// import FirebaseFirestoreSwift

class User {
//    @DocumentID private(set) var id: String?
    private(set) var id: String?
    private(set) var name: String
    private(set) var followees: [String?]
//    recipesRated (onlineID : Rating)

    init(id: String?, name: String, followees: [String?] = []) throws {
        self.id = id
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw UserError.emptyName
        }

        self.name = trimmedName
        self.followees = followees
    }
}

enum UserError: Error {
    case emptyName
}
