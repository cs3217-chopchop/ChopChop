enum VolumeUnit: Int, CaseIterable {
    static let baseUnit: VolumeUnit = .liter

    case pint
    case quart
    case gallon

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

    static func convert(_ value: Double, from currentUnit: VolumeUnit, to newUnit: VolumeUnit) -> Double {
        (value * currentUnit.ratioToLiter) / newUnit.ratioToLiter
    }

    static func convertToMass(_ value: Double, from volumeUnit: VolumeUnit, to massUnit: MassUnit) -> Double {
        (value * volumeUnit.ratioToLiter / QuantityType.massToVolumeBaseRatio) / massUnit.ratioToKilogram
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
}
