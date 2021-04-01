// import FirebaseFirestoreSwift

let USER_ID = UserDefaults.standard.string(forKey: "userId")


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

extension User: Codable {

}

enum UserError: Error {
    case emptyName
}
