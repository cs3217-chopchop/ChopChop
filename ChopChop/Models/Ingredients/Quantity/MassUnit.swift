enum MassUnit: Int, CaseIterable {
    static let baseUnit: MassUnit = .kilogram

    case ounce
    case pound

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

    static func convert(_ value: Double, from currentUnit: MassUnit, to newUnit: MassUnit) -> Double {
        (value * currentUnit.ratioToKilogram) / newUnit.ratioToKilogram
    }

    static func convertToVolume(_ value: Double, from massUnit: MassUnit, to volumeUnit: VolumeUnit) -> Double {
        (value * massUnit.ratioToKilogram * QuantityType.massToVolumeBaseRatio) / volumeUnit.ratioToLiter
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
}
