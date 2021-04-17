import GRDB

/**
 Represents the unit of a quantity.
 
 A unit can be of three types: count, mass or volume.
 */
enum QuantityUnit: Equatable, CaseIterable, Hashable {
    /// The conversion ratio from the mass base unit to the volume base unit.
    static let massToVolumeBaseRatio = 1.0

    case count
    case mass(MassUnit)
    case volume(VolumeUnit)

    /// The type of the unit.
    var type: QuantityType {
        switch self {
        case .count:
            return .count
        case .mass:
            return .mass
        case .volume:
            return .volume
        }
    }

    static var allCases: [QuantityUnit] {
        let countCases = [QuantityUnit.count]
        let massCases = MassUnit.allCases.map { QuantityUnit.mass($0) }
        let volumeCases = VolumeUnit.allCases.map { QuantityUnit.volume($0) }
        return countCases + massCases + volumeCases
    }
}

extension QuantityUnit: CustomStringConvertible {
    var description: String {
        switch self {
        case .count:
            return "count"
        case .mass(let unit):
            return unit.description
        case .volume(let unit):
            return unit.description
        }
    }
}
