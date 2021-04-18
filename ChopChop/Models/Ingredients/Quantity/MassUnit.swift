/**
 Represents a unit of the mass type.
 
 - Important: The cases are ordered in ascending size within each group (metric/imperial)
 */
enum MassUnit: Int, CaseIterable {
    static let baseUnit: MassUnit = .kilogram

    /// Imperial units
    case ounce
    case pound

    /// Metric units
    case gram
    case kilogram

    var isMetric: Bool {
        switch self {
        case .ounce, .pound:
            return false
        case .gram, .kilogram:
            return true
        }
    }

    /// The conversion ratio from the unit to kilogram.
    var ratioToKilogram: Double {
        switch self {
        case .ounce:
            return 0.028
        case .pound:
            return 0.454
        case .gram:
            return 0.001
        case .kilogram:
            return 1.0
        }
    }

    /**
     Converts the given value represented in `currentUnit` to the equivalent value represented in `newUnit`

     - Parameters:
        - `value`: The value to be converted.
        - `currentUnit`: The current unit in which the given value is expressed.
        - `newUnit`: The unit to which the given value is to be converted.
     */
    static func convert(_ value: Double, from currentUnit: MassUnit, to newUnit: MassUnit) -> Double {
        (value * currentUnit.ratioToKilogram) / newUnit.ratioToKilogram
    }

    /**
     Converts the given value represented in `massUnit` to the equivalent value represented in `volumeUnit`

     - Parameters:
        - `value`: The value to be converted.
        - `massUnit`: The mass unit in which the given value is expressed.
        - `volumeUnit`: The volume unit to which the given value is to be converted.
     */
    static func convertToVolume(_ value: Double, from massUnit: MassUnit, to volumeUnit: VolumeUnit) -> Double {
        (value * massUnit.ratioToKilogram * QuantityUnit.massToVolumeBaseRatio) / volumeUnit.ratioToLiter
    }
}

extension MassUnit: Comparable {
    static func < (lhs: MassUnit, rhs: MassUnit) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension MassUnit: CustomStringConvertible {
    var description: String {
        switch self {
        case .ounce:
            return "oz"
        case .pound:
            return "lb"
        case .gram:
            return "g"
        case .kilogram:
            return "kg"
        }
    }
}

extension MassUnit: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let description = try container.decode(String.self)
        let cases = MassUnit.allCases.reduce(into: [:]) { cases, unit in
            cases[unit.description] = unit
        }

        guard let unit = cases[description] else {
            throw DecodingError.valueNotFound(String.self,
                                              DecodingError.Context(codingPath: container.codingPath,
                                                                    debugDescription: "Unable to decode unit."))
        }

        self = unit
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.description)
    }
}
