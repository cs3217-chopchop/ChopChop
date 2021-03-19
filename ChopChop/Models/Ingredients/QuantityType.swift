enum QuantityType: Equatable {
    static let kilogramToLiterRatio = 1.0

    case count
    case mass(MassUnit)
    case volume(VolumeUnit)
}
