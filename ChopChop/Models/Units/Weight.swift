struct Mass: Quantity {
    var value: Double
    
    static func + (lhs: Mass, rhs: Mass) -> Mass {
        Mass(value: lhs.value + rhs.value)
    }
}
