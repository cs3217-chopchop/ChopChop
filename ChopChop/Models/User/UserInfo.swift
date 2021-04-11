import FirebaseFirestore
import FirebaseFirestoreSwift

final class UserInfo: Identifiable {
    @DocumentID private(set) var id: String?
    private(set) var name: String
    @ServerTimestamp var updatedAt: Date?

    init(id: String? = nil, name: String) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw UserError.emptyName
        }

        self.name = trimmedName
    }

}

extension UserInfo: Codable {

}
