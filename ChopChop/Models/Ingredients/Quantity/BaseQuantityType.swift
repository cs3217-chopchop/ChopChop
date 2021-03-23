import GRDB

enum BaseQuantityType: String, Equatable, Codable, DatabaseValueConvertible, CaseIterable {
    case count
    case mass
    case volume
}

extension BaseQuantityType: CustomStringConvertible {
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
