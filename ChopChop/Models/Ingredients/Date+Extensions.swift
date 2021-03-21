import Foundation

extension Date {
    static let today: Date = Calendar.current.startOfDay(for: Date())

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
