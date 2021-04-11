import Foundation

class User: UserInfo {
    private(set) var followees: [String]
    private(set) var ratings: [UserRating]

    init(id: String? = nil, name: String, updatedAt: Date? = nil, followees: [String] = [], ratings: [UserRating] = []) throws {
        self.followees = followees
        self.ratings = ratings
        try super.init(id: id, name: name, updatedAt: updatedAt)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case updatedAt
        case followees
        case ratings
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        followees = try values.decode([String].self, forKey: .followees)
        ratings = try values.decode([UserRating].self, forKey: .ratings)

//        let id = try values.decode(String.self, forKey: .id)
//        let name = try values.decode(String.self, forKey: .name)
//        let updatedAt = try values.decode(Date.self, forKey: .updatedAt)
//        try super.init(id: id, name: name, updatedAt: updatedAt)

        let superDecoder = try values.superDecoder()
        try super.init(from: superDecoder)

    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(followees, forKey: .followees)
        try container.encode(ratings, forKey: .ratings)
    }
}

enum UserError: Error {
    case emptyName
}
