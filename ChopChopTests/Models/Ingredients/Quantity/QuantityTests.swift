import XCTest

@testable import ChopChop

class QuantityTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }
}

// MARK: - Construct
extension QuantityType {
    func testConstruct_nonNegativeQuantity_success() {
        XCTAssertNoThrow(try Quantity(.count, value: 3))
        XCTAssertNoThrow(try Quantity(.mass(.baseUnit), value: 0))
    }

    func testConstruct_negativeQuantity_throwsError() {
        XCTAssertThrowsError(try Quantity(.volume(.baseUnit), value: -0.2))
    }
}

// MARK: - Plus
extension QuantityTests {
    func testPlus_sameQuantityTypeAndUnit_success() {
        XCTAssertEqual(
            try? Quantity(.count, value: 1) + Quantity(.count, value: 2),
            try? Quantity(.count, value: 1 + 2))

        XCTAssertEqual(
            try? Quantity(.mass(.baseUnit), value: 0.3) + Quantity(.mass(.baseUnit), value: 0.4),
            try? Quantity(.mass(.baseUnit), value: 0.3 + 0.4))

        XCTAssertEqual(
            try? Quantity(.volume(.baseUnit), value: 0.5) + Quantity(.volume(.baseUnit), value: 0.6),
            try? Quantity(.volume(.baseUnit), value: 0.5 + 0.6))
    }

    func testPlus_massMetricUnits_convertedToBiggerUnit() {
        XCTAssertEqual(
            try? Quantity(.mass(.gram), value: 1) + Quantity(.mass(.kilogram), value: 1),
            try? Quantity(.mass(.kilogram), value: 1.001))
    }

    func testPlus_massImperialUnits_convertedToBiggerUnit() {
        XCTAssertEqual(
            try? Quantity(.mass(.pound), value: 1) + Quantity(.mass(.ounce), value: 1),
            try? Quantity(.mass(.pound), value: 0.482 / 0.454))
    }

    func testPlus_volumeMetricUnits_convertedToBiggerUnit() {
        XCTAssertEqual(
            try? Quantity(.volume(.tablespoon), value: 1) + Quantity(.volume(.teaspoon), value: 1),
            try? Quantity(.volume(.tablespoon), value: 0.2 / 0.15))

        XCTAssertEqual(
            try? Quantity(.volume(.cup), value: 1) + Quantity(.volume(.milliliter), value: 100),
            try? Quantity(.volume(.milliliter), value: 350))

        XCTAssertEqual(
            try? Quantity(.volume(.milliliter), value: 1) + Quantity(.volume(.liter), value: 1),
            try? Quantity(.volume(.liter), value: 1.001))
    }

    func testPlus_volumeImperialUnits_convertedToBiggerUnit() {
        XCTAssertEqual(
            try? Quantity(.volume(.pint), value: 1) + Quantity(.volume(.quart), value: 1),
            try? Quantity(.volume(.quart), value: 1 * 0.5 / 0.95 + 1))
    }

    func testPlus_massAndVolume_convertedToLeftUnit() {
        XCTAssertEqual(
            try? Quantity(.mass(.gram), value: 300) + Quantity(.volume(.milliliter), value: 200),
            try? Quantity(.mass(.gram), value: 500))

        XCTAssertEqual(
            try? Quantity(.volume(.milliliter), value: 200) + Quantity(.mass(.gram), value: 300),
            try? Quantity(.volume(.milliliter), value: 500))
    }

    func testPlus_incompatibleQuantityTypes_throwsError() {
        XCTAssertThrowsError(try Quantity(.count, value: 1) + Quantity(.volume(.baseUnit), value: 0.5))
        XCTAssertThrowsError(try Quantity(.count, value: 1) + Quantity(.mass(.baseUnit), value: 0.5))
    }
}

// MARK: - Minus
extension QuantityTests {
    func testMinus_sameQuantityType_success() {
        XCTAssertEqual(
            try? Quantity(.count, value: 6) - Quantity(.count, value: 5),
            try? Quantity(.count, value: 6 - 5))

        XCTAssertEqual(
            try? Quantity(.mass(.baseUnit), value: 0.4) - Quantity(.mass(.baseUnit), value: 0.3),
            try? Quantity(.mass(.baseUnit), value: 0.4 - 0.3))

        XCTAssertEqual(
            try? Quantity(.volume(.baseUnit), value: 0.2) - Quantity(.volume(.baseUnit), value: 0.1),
            try? Quantity(.volume(.baseUnit), value: 0.2 - 0.1))
    }

    func testMinus_sameTypeDifferentUnit_convertToLeftUnit() {
        XCTAssertEqual(
            try? Quantity(.mass(.gram), value: 500) - Quantity(.mass(.kilogram), value: 0.3),
            try? Quantity(.mass(.gram), value: 200))

        XCTAssertEqual(
            try? Quantity(.volume(.milliliter), value: 500) - Quantity(.volume(.liter), value: 0.3),
            try? Quantity(.volume(.milliliter), value: 200))
    }

    func testMinus_massAndVolume_convertToLeftUnit() {
        XCTAssertEqual(
            try? Quantity(.mass(.gram), value: 500) - Quantity(.volume(.milliliter), value: 300),
            try? Quantity(.mass(.gram), value: 200))

        XCTAssertEqual(
            try? Quantity(.volume(.milliliter), value: 500) - Quantity(.mass(.gram), value: 300),
            try? Quantity(.volume(.milliliter), value: 200))
    }

    func testMinus_incompatibleQuantityTypes_throwsError() {
        XCTAssertThrowsError(try Quantity(.count, value: 1) - Quantity(.volume(.baseUnit), value: 0.5))
        XCTAssertThrowsError(try Quantity(.count, value: 1) - Quantity(.mass(.baseUnit), value: 0.5))
    }

    func testMinus_negativeResult_throwsError() {
        XCTAssertThrowsError(try Quantity(.volume(.baseUnit), value: 0.5) - Quantity(.volume(.baseUnit), value: 1))
    }
}

// MARK: - Times
extension QuantityTests {
    func testTimes_validResult_unitPreserved() {
        let factor: Double = 1.5
        XCTAssertEqual(
            try? Quantity(.count, value: 7) * factor,
            try? Quantity(.count, value: 7 * factor))
        XCTAssertEqual(
            try? Quantity(.mass(.gram), value: 0.8) * factor,
            try? Quantity(.mass(.gram), value: 0.8 * factor))
        XCTAssertEqual(
            try? Quantity(.volume(.cup), value: 0.9) * factor,
            try? Quantity(.volume(.cup), value: 0.9 * factor))
    }

    func testTimes_negativeResult_throwsError() {
        XCTAssertThrowsError(try Quantity(.mass(.baseUnit), value: 1) * -0.3)
        XCTAssertThrowsError(try Quantity(.mass(.baseUnit), value: 1) * -0.3)
    }
}

// MARK: - Arithmetic operations
extension QuantityTests {
    func testDivides_validResult_unitPreserved() {
        let factor: Double = 4

        XCTAssertEqual(
            try? Quantity(.count, value: 1.1) / factor,
            try? Quantity(.count, value: 1.1 / factor))
        XCTAssertEqual(
            try? Quantity(.mass(.ounce), value: 1.2) / factor,
            try? Quantity(.mass(.ounce), value: 1.2 / factor))
        XCTAssertEqual(
            try? Quantity(.volume(.liter), value: 1.3) / factor,
            try? Quantity(.volume(.liter), value: 1.3 / factor))
    }

    func testDivides_negativeResult_throwsError() {
        XCTAssertThrowsError(try Quantity(.volume(.baseUnit), value: 1.4) / -2)
    }

    func testDivides_zeroDivisor_throwsError() {
        XCTAssertThrowsError(try Quantity(.count, value: 1.5) / 0)
    }

    func testPlusEquals_sameQuantityType_success() {
        var leftCount = try? Quantity(.count, value: 1)
        XCTAssertNoThrow(try leftCount? += Quantity(.count, value: 2))
        XCTAssertEqual(leftCount, try? Quantity(.count, value: 1 + 2))

        var leftMass = try? Quantity(.mass(.baseUnit), value: 0.3)
        XCTAssertNoThrow(try leftMass? += Quantity(.mass(.baseUnit), value: 0.4))
        XCTAssertEqual(leftMass, try? Quantity(.mass(.baseUnit), value: 0.3 + 0.4))

        var leftVolume = try? Quantity(.volume(.baseUnit), value: 0.5)
        XCTAssertNoThrow(try leftVolume? += Quantity(.volume(.baseUnit), value: 0.6))
        XCTAssertEqual(leftVolume, try? Quantity(.volume(.baseUnit), value: 0.5 + 0.6))
    }

    func testPlusEquals_differentQuantityType_throwsError() {
        var left = try? Quantity(.count, value: 1)
        XCTAssertThrowsError(try left? += Quantity(.volume(.baseUnit), value: 0.5))
    }

    func testMinusEquals_sameQuantityType_success() {
        var leftCount = try? Quantity(.count, value: 6)
        XCTAssertNoThrow(try leftCount? -= Quantity(.count, value: 5))
        XCTAssertEqual(leftCount, try? Quantity(.count, value: 6 - 5))

        var leftMass = try? Quantity(.mass(.baseUnit), value: 0.4)
        XCTAssertNoThrow(try leftMass? -= Quantity(.mass(.baseUnit), value: 0.3))
        XCTAssertEqual(leftMass, try? Quantity(.mass(.baseUnit), value: 0.4 - 0.3))

        var leftVolume = try? Quantity(.volume(.baseUnit), value: 0.2)
        XCTAssertNoThrow(try leftVolume? -= Quantity(.volume(.baseUnit), value: 0.1))
        XCTAssertEqual(leftVolume, try? Quantity(.volume(.baseUnit), value: 0.2 - 0.1))
    }

    func testMinusEquals_differentQuantityType_throwsError() {
        var left = try? Quantity(.count, value: 1)
        XCTAssertThrowsError(try left? -= Quantity(.volume(.baseUnit), value: 0.5))
    }

    func testMinusEquals_negativeResult_throwsError() {
        var left = try? Quantity(.volume(.baseUnit), value: 0.5)
        XCTAssertThrowsError(try left? -= Quantity(.volume(.baseUnit), value: 1))
    }

    func testTimesEquals_validResult_success() {
        var testCount = try? Quantity(.count, value: 7)
        var testMass = try? Quantity(.mass(.baseUnit), value: 0.8)
        var testVolume = try? Quantity(.volume(.baseUnit), value: 0.9)
        let factor: Double = 1.5

        XCTAssertNoThrow(try testCount? *= factor)
        XCTAssertNoThrow(try testMass? *= factor)
        XCTAssertNoThrow(try testVolume? *= factor)

        XCTAssertEqual(testCount, try? Quantity(.count, value: 7 * factor))
        XCTAssertEqual(testMass, try? Quantity(.mass(.baseUnit), value: 0.8 * factor))
        XCTAssertEqual(testVolume, try? Quantity(.volume(.baseUnit), value: 0.9 * factor))
    }

    func testTimesEquals_negativeResult_throwsError() {
        var quantity = try? Quantity(.mass(.baseUnit), value: 1)
        let factor: Double = -0.3

        XCTAssertThrowsError(try quantity? *= factor)
    }

    func testDividesEquals_validResult_success() {
        var testCount = try? Quantity(.count, value: 1.1)
        var testMass = try? Quantity(.mass(.baseUnit), value: 1.2)
        var testVolume = try? Quantity(.volume(.baseUnit), value: 1.3)
        let factor: Double = 4

        XCTAssertNoThrow(try testCount? /= factor)
        XCTAssertNoThrow(try testMass? /= factor)
        XCTAssertNoThrow(try testVolume? /= factor)

        XCTAssertEqual(testCount, try? Quantity(.count, value: 1.1 / factor))
        XCTAssertEqual(testMass, try? Quantity(.mass(.baseUnit), value: 1.2 / factor))
        XCTAssertEqual(testVolume, try? Quantity(.volume(.baseUnit), value: 1.3 / factor))
    }

    func testDividesEquals_negativeResult_throwsError() {
        var quantity = try? Quantity(.volume(.baseUnit), value: 1.4)
        let factor: Double = -2

        XCTAssertThrowsError(try quantity? /= factor)
    }

    func testDividesEquals_zeroDivisor_throwsError() {
        var quantity = try? Quantity(.count, value: 1.4)
        let factor: Double = 0

        XCTAssertThrowsError(try quantity? /= factor)
    }
}

// MARK: - Comparable
extension QuantityTests {
    func testLessThan_sameQuantityType_success() throws {
        let leftCount = try Quantity(.count, value: 1)
        let rightCount = try Quantity(.count, value: 2)
        XCTAssertTrue(try leftCount < rightCount)

        let leftMass = try Quantity(.mass(.ounce), value: 3)
        let rightMass = try Quantity(.mass(.kilogram), value: 1)
        XCTAssertTrue(try leftMass < rightMass)

        let leftVolume = try Quantity(.volume(.cup), value: 3)
        let rightVolume = try Quantity(.volume(.liter), value: 1)
        XCTAssertTrue(try leftVolume < rightVolume)
    }

    func testLessThan_massAndVolume_success() throws {
        let leftVolume = try Quantity(.volume(.milliliter), value: 20)
        let rightMass = try Quantity(.mass(.kilogram), value: 1)
        XCTAssertTrue(try leftVolume < rightMass)

        let leftMass = try Quantity(.mass(.gram), value: 20)
        let rightVolume = try Quantity(.volume(.liter), value: 1)
        XCTAssertTrue(try leftMass < rightVolume)
    }

    func testEqualTo_sameQuantityTypeAndUnit_success() throws {
        let leftCount = try Quantity(.count, value: 1)
        let rightCount = try Quantity(.count, value: 1)
        let differentCount = try Quantity(.count, value: 2)
        XCTAssertEqual(leftCount, rightCount)
        XCTAssertNotEqual(leftCount, differentCount)

        let leftMass = try Quantity(.mass(.ounce), value: 0.3)
        let rightMass = try Quantity(.mass(.ounce), value: 0.3)
        let differentMass = try Quantity(.mass(.ounce), value: 0.4)
        let differentUnitMass = try Quantity(.mass(.gram), value: 0.3)
        XCTAssertEqual(leftMass, rightMass)
        XCTAssertNotEqual(leftMass, differentMass)
        XCTAssertNotEqual(leftMass, differentUnitMass)

        let leftVolume = try Quantity(.volume(.cup), value: 0.5)
        let rightVolume = try Quantity(.volume(.cup), value: 0.5)
        let differentVolume = try Quantity(.volume(.cup), value: 0.6)
        let differentUnitVolume = try Quantity(.volume(.teaspoon), value: 0.5)
        XCTAssertEqual(leftVolume, rightVolume)
        XCTAssertNotEqual(leftVolume, differentVolume)
        XCTAssertNotEqual(leftVolume, differentUnitVolume)
    }

    func testEqualTo_differentQuantityTypes_returnsFalse() throws {
        let left = try Quantity(.count, value: 1)
        let right = try Quantity(.volume(.baseUnit), value: 0.5)

        XCTAssertNotEqual(left, right)
    }
}
