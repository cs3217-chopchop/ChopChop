enum Quantity {
    case count(Double)
    case mass(Double)
    case volume(Double)
}

extension Quantity: Codable {
    enum CodingKeys: CodingKey {
        case count, mass, volume
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let value = try container.decodeIfPresent(Double.self, forKey: .count) {
            self = .count(value)
        } else if let value = try container.decodeIfPresent(Double.self, forKey: .mass) {
            self = .mass(value)
        } else if let value = try container.decodeIfPresent(Double.self, forKey: .volume) {
            self = .volume(value)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath,
                                                                    debugDescription: "Unable to decode enum."))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .count(let value):
            try container.encode(value, forKey: .count)
        case .mass(let value):
            try container.encode(value, forKey: .mass)
        case .volume(let value):
            try container.encode(value, forKey: .volume)
        }
    }
}
