struct Count: Quantity, Equatable, CustomStringConvertible {
    private var value: Double
    
    var description: String {
        return String(value)
    }
    
    init(_ value: Double) {
        self.value = value
    }
    
    static func + (lhs: Count, rhs: Count) -> Count {
        Count(lhs.value + rhs.value)
    }
    
    static func - (lhs: Count, rhs: Count) -> Count {
        Count(lhs.value - rhs.value)
    }
}
