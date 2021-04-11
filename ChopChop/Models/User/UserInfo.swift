import FirebaseFirestore
import FirebaseFirestoreSwift

class UserInfo: Identifiable, Codable {
    @DocumentID private(set) var id: String?
    private(set) var name: String
    @ServerTimestamp var updatedAt: Date?

    init(id: String? = nil, name: String, updatedAt: Date? = nil) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw UserError.emptyName
        }

        self.name = trimmedName

        guard let updatedAt = updatedAt else {
            return
        }
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case updatedAt
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        updatedAt = try values.decode(Date.self, forKey: .updatedAt)
        id = try values.decode(String.self, forKey: .id)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
}
