enum QuantityType: Equatable {
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

enum BaseQuantityType: Equatable {
    case count
    case mass
    case volume
}
