import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class User: Identifiable {
    @DocumentID private(set) var id: String?
    private(set) var name: String
    private(set) var followees: [String]
    private(set) var ratings: [UserRating]

    init(id: String? = nil, name: String, followees: [String] = [], ratings: [UserRating] = []) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw UserError.emptyName
        }
        self.name = trimmedName

        self.followees = followees
        self.ratings = ratings
        self.followees = followees
        self.ratings = ratings
    }

}

extension User: Codable {

}

enum UserError: Error {
    case emptyName
}
