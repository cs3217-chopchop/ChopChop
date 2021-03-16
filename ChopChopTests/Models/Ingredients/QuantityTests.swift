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
        XCTAssertNoThrow(try Quantity(.mass, value: 0))
    }

    func testConstruct_negativeQuantity_throwsError() {
        XCTAssertThrowsError(try Quantity(.volume, value: -0.2))
    }
}

// MARK: - Arithmetic operations
extension QuantityTests {
    func testPlus_sameQuantityType_success() {
        XCTAssertEqual(
            try? Quantity(.count, value: 1) + Quantity(.count, value: 2),
            try? Quantity(.count, value: 1 + 2))

        XCTAssertEqual(
            try? Quantity(.mass, value: 0.3) + Quantity(.mass, value: 0.4),
            try? Quantity(.mass, value: 0.3 + 0.4))

        XCTAssertEqual(
            try? Quantity(.volume, value: 0.5) + Quantity(.volume, value: 0.6),
            try? Quantity(.volume, value: 0.5 + 0.6))
    }

    func testPlus_differentQuantityType_throwsError() {
        XCTAssertThrowsError(try Quantity(.count, value: 1) + Quantity(.volume, value: 0.5))
    }

    func testPlus_negativeResult_throwsError() {
        XCTAssertThrowsError(try Quantity(.volume, value: -1) + Quantity(.volume, value: 0.5))
    }

    func testMinus_sameQuantityType_success() {
        XCTAssertEqual(
            try? Quantity(.count, value: 6) - Quantity(.count, value: 5),
            try? Quantity(.count, value: 6 - 5))

        XCTAssertEqual(
            try? Quantity(.mass, value: 0.4) - Quantity(.mass, value: 0.3),
            try? Quantity(.mass, value: 0.4 - 0.3))

        XCTAssertEqual(
            try? Quantity(.volume, value: 0.2) - Quantity(.volume, value: 0.1),
            try? Quantity(.volume, value: 0.2 - 0.1))
    }

    func testMinus_differentQuantityType_throwsError() {
        XCTAssertThrowsError(try Quantity(.count, value: 1) - Quantity(.volume, value: 0.5))
    }

    func testMinus_negativeResult_throwsError() {
        XCTAssertThrowsError(try Quantity(.volume, value: 0.5) - Quantity(.volume, value: 1))
    }

    func testTimes_validResult_success() {
        let factor: Double = 1.5

        XCTAssertEqual(
            try? Quantity(.count, value: 7) * factor,
            try? Quantity(.count, value: 7 * factor))
        XCTAssertEqual(
            try? Quantity(.mass, value: 0.8) * factor,
            try? Quantity(.mass, value: 0.8 * factor))
        XCTAssertEqual(
            try? Quantity(.volume, value: 0.9) * factor,
            try? Quantity(.volume, value: 0.9 * factor))
    }

    func testTimes_negativeResult_throwsError() {
        XCTAssertThrowsError(try Quantity(.mass, value: 1) * -0.3)
    }

    func testDivides_validResult_success() {
        let factor: Double = 4

        XCTAssertEqual(
            try? Quantity(.count, value: 1.1) / factor,
            try? Quantity(.count, value: 1.1 / factor))
        XCTAssertEqual(
            try? Quantity(.mass, value: 1.2) / factor,
            try? Quantity(.mass, value: 1.2 / factor))
        XCTAssertEqual(
            try? Quantity(.volume, value: 1.3) / factor,
            try? Quantity(.volume, value: 1.3 / factor))
    }

    func testDivides_negativeResult_throwsError() {
        XCTAssertThrowsError(try Quantity(.volume, value: 1.4) / -2)
    }

    func testDivides_zeroDivisor_throwsError() {
        XCTAssertThrowsError(try Quantity(.count, value: 1.5) / 0)
    }

    func testPlusEquals_sameQuantityType_success() {
        var leftCount = try? Quantity(.count, value: 1)
        XCTAssertNoThrow(try leftCount? += Quantity(.count, value: 2))
        XCTAssertEqual(leftCount, try? Quantity(.count, value: 1 + 2))

        var leftMass = try? Quantity(.mass, value: 0.3)
        XCTAssertNoThrow(try leftMass? += Quantity(.mass, value: 0.4))
        XCTAssertEqual(leftMass, try? Quantity(.mass, value: 0.3 + 0.4))

        var leftVolume = try? Quantity(.volume, value: 0.5)
        XCTAssertNoThrow(try leftVolume? += Quantity(.volume, value: 0.6))
        XCTAssertEqual(leftVolume, try? Quantity(.volume, value: 0.5 + 0.6))
    }

    func testPlusEquals_differentQuantityType_throwsError() {
        var left = try? Quantity(.count, value: 1)
        XCTAssertThrowsError(try left? += Quantity(.volume, value: 0.5))
    }

    func testMinusEquals_sameQuantityType_success() {
        var leftCount = try? Quantity(.count, value: 6)
        XCTAssertNoThrow(try leftCount? -= Quantity(.count, value: 5))
        XCTAssertEqual(leftCount, try? Quantity(.count, value: 6 - 5))

        var leftMass = try? Quantity(.mass, value: 0.4)
        XCTAssertNoThrow(try leftMass? -= Quantity(.mass, value: 0.3))
        XCTAssertEqual(leftMass, try? Quantity(.mass, value: 0.4 - 0.3))

        var leftVolume = try? Quantity(.volume, value: 0.2)
        XCTAssertNoThrow(try leftVolume? -= Quantity(.volume, value: 0.1))
        XCTAssertEqual(leftVolume, try? Quantity(.volume, value: 0.2 - 0.1))
    }

    func testMinusEquals_differentQuantityType_throwsError() {
        var left = try? Quantity(.count, value: 1)
        XCTAssertThrowsError(try left? -= Quantity(.volume, value: 0.5))
    }

    func testMinusEquals_negativeResult_throwsError() {
        var left = try? Quantity(.volume, value: 0.5)
        XCTAssertThrowsError(try left? -= Quantity(.volume, value: 1))
    }

    func testTimesEquals_validResult_success() {
        var testCount = try? Quantity(.count, value: 7)
        var testMass = try? Quantity(.mass, value: 0.8)
        var testVolume = try? Quantity(.volume, value: 0.9)
        let factor: Double = 1.5

        XCTAssertNoThrow(try testCount? *= factor)
        XCTAssertNoThrow(try testMass? *= factor)
        XCTAssertNoThrow(try testVolume? *= factor)

        XCTAssertEqual(testCount, try? Quantity(.count, value: 7 * factor))
        XCTAssertEqual(testMass, try? Quantity(.mass, value: 0.8 * factor))
        XCTAssertEqual(testVolume, try? Quantity(.volume, value: 0.9 * factor))
    }

    func testTimesEquals_negativeResult_throwsError() {
        var quantity = try? Quantity(.mass, value: 1)
        let factor: Double = -0.3

        XCTAssertThrowsError(try quantity? *= factor)
    }

    func testDividesEquals_validResult_success() {
        var testCount = try? Quantity(.count, value: 1.1)
        var testMass = try? Quantity(.mass, value: 1.2)
        var testVolume = try? Quantity(.volume, value: 1.3)
        let factor: Double = 4

        XCTAssertNoThrow(try testCount? /= factor)
        XCTAssertNoThrow(try testMass? /= factor)
        XCTAssertNoThrow(try testVolume? /= factor)

        XCTAssertEqual(testCount, try? Quantity(.count, value: 1.1 / factor))
        XCTAssertEqual(testMass, try? Quantity(.mass, value: 1.2 / factor))
        XCTAssertEqual(testVolume, try? Quantity(.volume, value: 1.3 / factor))
    }

    func testDividesEquals_negativeResult_throwsError() {
        var quantity = try? Quantity(.volume, value: 1.4)
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
        XCTAssertLessThan(leftCount, rightCount)

        let leftMass = try Quantity(.mass, value: 0.3)
        let rightMass = try Quantity(.mass, value: 0.4)
        XCTAssertLessThan(leftMass, rightMass)

        let leftVolume = try Quantity(.volume, value: 0.5)
        let rightVolume = try Quantity(.volume, value: 0.6)
        XCTAssertLessThan(leftVolume, rightVolume)
    }

    func testLessThan_equalQuantities_returnsFalse() throws {
        let left = try Quantity(.count, value: 3)
        let right = try Quantity(.count, value: 3)
        XCTAssertLessThanOrEqual(left, right)
    }

    func testEqualTo_sameQuantityType_success() throws {
        let leftCount = try Quantity(.count, value: 1)
        let rightCount = try Quantity(.count, value: 1)
        let differentCount = try Quantity(.count, value: 2)
        XCTAssertEqual(leftCount, rightCount)
        XCTAssertNotEqual(leftCount, differentCount)

        let leftMass = try Quantity(.mass, value: 0.3)
        let rightMass = try Quantity(.mass, value: 0.3)
        let differentMass = try Quantity(.mass, value: 0.4)
        XCTAssertEqual(leftMass, rightMass)
        XCTAssertNotEqual(leftMass, differentMass)

        let leftVolume = try Quantity(.volume, value: 0.5)
        let rightVolume = try Quantity(.volume, value: 0.5)
        let differentVolume = try Quantity(.volume, value: 0.6)
        XCTAssertEqual(leftVolume, rightVolume)
        XCTAssertNotEqual(leftVolume, differentVolume)
    }

    func testEqualTo_differentQuantityTypes_returnsFalse() throws {
        let left = try Quantity(.count, value: 1)
        let right = try Quantity(.volume, value: 0.5)

        XCTAssertNotEqual(left, right)
    }
}
