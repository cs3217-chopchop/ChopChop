/**
 Represents a unit of the volume type.
 
 - Important: The cases are ordered in ascending size within each group (metric/imperial)
 */
enum VolumeUnit: Int, CaseIterable {
    static let baseUnit: VolumeUnit = .liter

    /// Imperial units
    case pint
    case quart
    case gallon

    /// Metric units
    case teaspoon
    case tablespoon
    case cup
    case milliliter
    case liter

    var isMetric: Bool {
        switch self {
        case .pint, .quart, .gallon:
            return false
        case .teaspoon, .tablespoon, .cup, .milliliter, .liter:
            return true
        }
    }

    /// The conversion ratio from the unit to liter.
    var ratioToLiter: Double {
        switch self {
        case .pint:
            return 0.5
        case .quart:
            return 0.95
        case .gallon:
            return 3.8
        case .teaspoon:
            return 0.005
        case .tablespoon:
            return 0.015
        case .cup:
            return 0.25
        case .milliliter:
            return 0.001
        case .liter:
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
    static func convert(_ value: Double, from currentUnit: VolumeUnit, to newUnit: VolumeUnit) -> Double {
        (value * currentUnit.ratioToLiter) / newUnit.ratioToLiter
    }

    /**
     Converts the given value represented in `volumeUnit` to the equivalent value represented in `massUnit`

     - Parameters:
        - `value`: The value to be converted.
        - `volumeUnit`: The volume unit in which the given value is expressed.
        - `massUnit`: The mass unit to which the given value is to be converted.
     */
    static func convertToMass(_ value: Double, from volumeUnit: VolumeUnit, to massUnit: MassUnit) -> Double {
        (value * volumeUnit.ratioToLiter / QuantityUnit.massToVolumeBaseRatio) / massUnit.ratioToKilogram
    }
}

extension VolumeUnit: Comparable {
    static func < (lhs: VolumeUnit, rhs: VolumeUnit) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension VolumeUnit: CustomStringConvertible {
    var description: String {
        switch self {
        case .pint:
            return "pints"
        case .quart:
            return "quarts"
        case .gallon:
            return "gallons"
        case .teaspoon:
            return "tsp"
        case .tablespoon:
            return "tbsp"
        case .cup:
            return "cups"
        case .milliliter:
            return "ml"
        case .liter:
            return "L"
        }
    }
}

extension VolumeUnit: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let description = try container.decode(String.self)

        switch description {
        case "pints":
            self = .pint
        case "quarts":
            self = .quart
        case "gallons":
            self = .gallon
        case "tsp":
            self = .teaspoon
        case "tbsp":
            self = .tablespoon
        case "cups":
            self = .cup
        case "ml":
            self = .milliliter
        case "L":
            self = .liter
        default:
            throw DecodingError.valueNotFound(String.self,
                                              DecodingError.Context(codingPath: container.codingPath,
                                                                    debugDescription: "Unable to decode unit."))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.description)
    }
}
