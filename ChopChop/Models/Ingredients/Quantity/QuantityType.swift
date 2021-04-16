import GRDB

/**
 Represents the type of a quantity.
 */
enum QuantityType: String, Equatable, Codable, DatabaseValueConvertible, CaseIterable {
    case count
    case mass
    case volume
}

extension QuantityType: CustomStringConvertible {
    var description: String {
        switch self {
        case .count:
            return "Count"
        case .mass:
            return "Mass"
        case .volume:
            return "Volume"
        }
    }
}
