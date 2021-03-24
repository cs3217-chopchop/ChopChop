import GRDB
enum QuantityType: Equatable, CaseIterable, Hashable {
    static var allCases: [QuantityType] {
        [
            .count, .mass(.gram), .mass(.kilogram), .mass(.ounce), .mass(.pound), .volume(.cup),
            .volume(.gallon), .volume(.liter), .volume(.milliliter), .volume(.pint), .volume(.quart),
            .volume(.tablespoon), .volume(.teaspoon)
        ]
    }

    static let massToVolumeBaseRatio = 1.0

    case count
    case mass(MassUnit)
    case volume(VolumeUnit)

    var baseType: BaseQuantityType {
        switch self {
        case .count:
            return .count
        case .mass:
            return .mass
        case .volume:
            return .volume
        }
    }
}

extension QuantityType: CustomStringConvertible {
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

enum BaseQuantityType: String, Equatable, Codable, DatabaseValueConvertible, CaseIterable {
    case count
    case mass
    case volume
}
