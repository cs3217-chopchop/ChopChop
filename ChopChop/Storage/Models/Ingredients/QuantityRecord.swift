enum QuantityRecord: Equatable {
    case count(Double)
    case mass(Double, MassUnit)
    case volume(Double, VolumeUnit)
}

extension QuantityRecord: Codable {
    enum CodingKeys: CodingKey {
        case count, mass, volume, unit
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let value = try container.decodeIfPresent(Double.self, forKey: .count) {
            self = .count(value)
        } else if let value = try container.decodeIfPresent(Double.self, forKey: .mass),
                  let unit = try container.decodeIfPresent(MassUnit.self, forKey: .unit) {
            self = .mass(value, unit)
        } else if let value = try container.decodeIfPresent(Double.self, forKey: .volume),
                  let unit = try container.decodeIfPresent(VolumeUnit.self, forKey: .unit) {
            self = .volume(value, unit)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath,
                                                                    debugDescription: "Unable to decode enum."))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .count(value):
            try container.encode(value, forKey: .count)
        case let .mass(value, unit):
            try container.encode(value, forKey: .mass)
            try container.encode(unit, forKey: .unit)
        case let .volume(value, unit):
            try container.encode(value, forKey: .volume)
            try container.encode(unit, forKey: .unit)
        }
    }
}
