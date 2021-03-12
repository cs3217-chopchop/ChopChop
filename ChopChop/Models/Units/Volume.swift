// import Foundation
//
// struct Volume: Quantity {
//    private var value: Double
//    
//    var description: String {
//        let formatter = NumberFormatter()
//        formatter.minimumFractionDigits = 0
//        formatter.maximumFractionDigits = .max
//        
//        if value / Unit.litre.ratio >= 1 {
//            return "\(formatter.string(from: (value / Unit.litre.ratio) as NSNumber) ?? "") \(Unit.litre)"
//        } else {
//            return "\(formatter.string(from: (value / Unit.millilitre.ratio) as NSNumber) ?? "") \(Unit.millilitre)"
//        }
//    }
//    
//    init(_ value: Double, _ unit: Unit = .litre) {
//        self.value = value * unit.ratio
//    }
//    
//    static func + (lhs: Volume, rhs: Volume) -> Volume {
//        Volume(lhs.value + rhs.value)
//    }
//    
//    static func - (lhs: Volume, rhs: Volume) -> Volume {
//        Volume(lhs.value - rhs.value)
//    }
// }
//
// extension Volume {
//    enum Unit: CustomStringConvertible {
//        case litre, litres
//        case millilitre, millilitres
//        
//        var description: String {
//            switch self {
//            case .litre, .litres:
//                return "L"
//            case .millilitre, .millilitres:
//                return "ml"
//            }
//        }
//        
//        var ratio: Double {
//            switch self {
//            case .litre, .litres:
//                return 1
//            case .millilitre, .millilitres:
//                return 0.001
//            }
//        }
//    }
// }
