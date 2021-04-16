import FirebaseFirestore
import FirebaseFirestoreSwift

struct UserInfoRecord: InfoRecord {
    @DocumentID var id: String?
    private(set) var name: String
    @ServerTimestamp var updatedAt: Date?
    @ServerTimestamp var createdAt: Date? // actually dont need but convention

    init(id: String? = nil, name: String) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw UserError.emptyName
        }

        self.name = trimmedName
    }

}
