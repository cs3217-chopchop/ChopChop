import Foundation

struct User: Identifiable, CachableEntity {
    let id: String
    let name: String
    let followees: [String]
    let ratings: [UserRating]
    let createdAt: Date
    let updatedAt: Date

    init(id: String, name: String, followees: [String], ratings: [UserRating], createdAt: Date, updatedAt: Date) throws {
        self.id = id
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw UserError.emptyName
        }
        self.name = trimmedName

        self.followees = followees
        self.ratings = ratings
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

}

extension User {
    init?(from record: UserRecord, infoRecord: UserInfoRecord) {
        guard let id = record.id, let createdAt = infoRecord.createdAt, let updatedAt = infoRecord.updatedAt else {
            return nil // TODO: or throw errors?
        }

        self.id = id
        self.name = record.name
        self.followees = record.followees
        self.ratings = record.ratings
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum UserError: Error {
    case emptyName
}
