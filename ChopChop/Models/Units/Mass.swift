//import Foundation
//
//struct Mass: Quantity {
//    private var value: Double
//    
//    var description: String {
//        let formatter = NumberFormatter()
//        formatter.minimumFractionDigits = 0
//        formatter.maximumFractionDigits = .max
//        
//        if value / Unit.kilogram.ratio >= 1 {
//            return "\(formatter.string(from: (value / Unit.kilogram.ratio) as NSNumber) ?? "") \(Unit.kilogram)"
//        } else {
//            return "\(formatter.string(from: (value / Unit.gram.ratio) as NSNumber) ?? "") \(Unit.gram)"
//        }
//    }
//    
//    init(_ value: Double, _ unit: Unit = .kilogram) {
//        self.value = value * unit.ratio
//    }
//    
//    static func + (lhs: Mass, rhs: Mass) -> Mass {
//        Mass(lhs.value + rhs.value)
//    }
//    
//    static func - (lhs: Mass, rhs: Mass) -> Mass {
//        Mass(lhs.value - rhs.value)
//    }
//}
//
//extension Mass {
//    enum Unit: CustomStringConvertible {
//        case kilogram, kilograms
//        case gram, grams
//        
//        var description: String {
//            switch self {
//            case .kilogram, .kilograms:
//                return "kg"
//            case .gram, .grams:
//                return "g"
//            }
//        }
//        
//        var ratio: Double {
//            switch self {
//            case .kilogram, .kilograms:
//                return 1
//            case .gram, .grams:
//                return 0.001
//            }
//        }
//    }
//}
