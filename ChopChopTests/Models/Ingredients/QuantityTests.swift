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

// MARK: - Arithmetic operations
extension QuantityTests {
    func testPlus_sameQuantityType_success() {
        let leftCount: Quantity = .count(1)
        let rightCount: Quantity = .count(2)
        XCTAssertEqual(try? leftCount + rightCount, .count(1 + 2))

        let leftMass: Quantity = .mass(0.3)
        let rightMass: Quantity = .mass(0.4)
        XCTAssertEqual(try? leftMass + rightMass, .mass(0.3 + 0.4))

        let leftVolume: Quantity = .volume(0.5)
        let rightVolume: Quantity = .volume(0.6)
        XCTAssertEqual(try? leftVolume + rightVolume, .volume(0.5 + 0.6))
    }

    func testPlus_differentQuantityType_throwsError() {
        let left: Quantity = .count(1)
        let right: Quantity = .volume(0.5)

        XCTAssertThrowsError(try left + right)
    }

    func testPlus_negativeResult_throwsError() {
        let left: Quantity = .volume(-1)
        let right: Quantity = .volume(0.5)

        XCTAssertThrowsError(try left + right)
    }

    func testMinus_sameQuantityType_success() {
        let leftCount: Quantity = .count(6)
        let rightCount: Quantity = .count(5)
        XCTAssertEqual(try? leftCount - rightCount, .count(6 - 5))

        let leftMass: Quantity = .mass(0.4)
        let rightMass: Quantity = .mass(0.3)
        XCTAssertEqual(try? leftMass - rightMass, .mass(0.4 - 0.3))

        let leftVolume: Quantity = .volume(0.2)
        let rightVolume: Quantity = .volume(0.1)
        XCTAssertEqual(try? leftVolume - rightVolume, .volume(0.2 - 0.1))
    }

    func testMinus_differentQuantityType_throwsError() {
        let left: Quantity = .count(1)
        let right: Quantity = .volume(0.5)

        XCTAssertThrowsError(try left - right)
    }

    func testMinus_negativeResult_throwsError() {
        let left: Quantity = .volume(0.5)
        let right: Quantity = .volume(1)

        XCTAssertThrowsError(try left - right)
    }

    func testTimes_validResult_success() {
        let testCount: Quantity = .count(7)
        let testMass: Quantity = .mass(0.8)
        let testVolume: Quantity = .volume(0.9)
        let factor: Double = 1.5

        XCTAssertEqual(try? testCount * factor, .count(7 * factor))
        XCTAssertEqual(try? testMass * factor, .mass(0.8 * factor))
        XCTAssertEqual(try? testVolume * factor, .volume(0.9 * factor))
    }

    func testTimes_negativeResult_throwsError() {
        let quantity: Quantity = .mass(1)
        let factor: Double = -0.3

        XCTAssertThrowsError(try quantity * factor)
    }

    func testDivides_validResult_success() {
        let testCount: Quantity = .count(1.1)
        let testMass: Quantity = .mass(1.2)
        let testVolume: Quantity = .volume(1.3)
        let factor: Double = 4

        XCTAssertEqual(try? testCount / factor, .count(1.1 / factor))
        XCTAssertEqual(try? testMass / factor, .mass(1.2 / factor))
        XCTAssertEqual(try? testVolume / factor, .volume(1.3 / factor))
    }

    func testDivides_negativeResult_throwsError() {
        let quantity: Quantity = .volume(1.4)
        let factor: Double = -2

        XCTAssertThrowsError(try quantity / factor)
    }

    func testDivides_zeroDivisor_throwsError() {
        let quantity: Quantity = .count(1.5)
        let factor: Double = 0

        XCTAssertThrowsError(try quantity / factor)
    }

    func testPlusEquals_sameQuantityType_success() {
        var leftCount: Quantity = .count(1)
        let rightCount: Quantity = .count(2)
        XCTAssertNoThrow(try leftCount += rightCount)
        XCTAssertEqual(leftCount, .count(1 + 2))

        var leftMass: Quantity = .mass(0.3)
        let rightMass: Quantity = .mass(0.4)
        XCTAssertNoThrow(try leftMass += rightMass)
        XCTAssertEqual(leftMass, .mass(0.3 + 0.4))

        var leftVolume: Quantity = .volume(0.5)
        let rightVolume: Quantity = .volume(0.6)
        XCTAssertNoThrow(try leftVolume += rightVolume)
        XCTAssertEqual(leftVolume, .volume(0.5 + 0.6))
    }

    func testPlusEquals_differentQuantityType_throwsError() {
        var left: Quantity = .count(1)
        let right: Quantity = .volume(0.5)

        XCTAssertThrowsError(try left += right)
    }

    func testPlusEquals_negativeResult_throwsError() {
        var left: Quantity = .volume(-1)
        let right: Quantity = .volume(0.5)

        XCTAssertThrowsError(try left += right)
    }

    func testMinusEquals_sameQuantityType_success() {
        var leftCount: Quantity = .count(6)
        let rightCount: Quantity = .count(5)
        XCTAssertNoThrow(try leftCount -= rightCount)
        XCTAssertEqual(leftCount, .count(6 - 5))

        var leftMass: Quantity = .mass(0.4)
        let rightMass: Quantity = .mass(0.3)
        XCTAssertNoThrow(try leftMass -= rightMass)
        XCTAssertEqual(leftMass, .mass(0.4 - 0.3))

        var leftVolume: Quantity = .volume(0.2)
        let rightVolume: Quantity = .volume(0.1)
        XCTAssertNoThrow(try leftVolume -= rightVolume)
        XCTAssertEqual(leftVolume, .volume(0.2 - 0.1))
    }

    func testMinusEquals_differentQuantityType_throwsError() {
        var left: Quantity = .count(1)
        let right: Quantity = .volume(0.5)

        XCTAssertThrowsError(try left -= right)
    }

    func testMinusEquals_negativeResult_throwsError() {
        var left: Quantity = .volume(0.5)
        let right: Quantity = .volume(1)

        XCTAssertThrowsError(try left -= right)
    }

    func testTimesEquals_validResult_success() {
        var testCount: Quantity = .count(7)
        var testMass: Quantity = .mass(0.8)
        var testVolume: Quantity = .volume(0.9)
        let factor: Double = 1.5

        XCTAssertNoThrow(try testCount *= factor)
        XCTAssertNoThrow(try testMass *= factor)
        XCTAssertNoThrow(try testVolume *= factor)
        XCTAssertEqual(testCount, .count(7 * factor))
        XCTAssertEqual(testMass, .mass(0.8 * factor))
        XCTAssertEqual(testVolume, .volume(0.9 * factor))
    }

    func testTimesEquals_negativeResult_throwsError() {
        var quantity: Quantity = .mass(1)
        let factor: Double = -0.3

        XCTAssertThrowsError(try quantity *= factor)
    }

    func testDividesEquals_validResult_success() {
        var testCount: Quantity = .count(1.1)
        var testMass: Quantity = .mass(1.2)
        var testVolume: Quantity = .volume(1.3)
        let factor: Double = 4

        XCTAssertNoThrow(try testCount /= factor)
        XCTAssertNoThrow(try testMass /= factor)
        XCTAssertNoThrow(try testVolume /= factor)
        XCTAssertEqual(testCount, .count(1.1 / factor))
        XCTAssertEqual(testMass, .mass(1.2 / factor))
        XCTAssertEqual(testVolume, .volume(1.3 / factor))
    }

    func testDividesEquals_negativeResult_throwsError() {
        var quantity: Quantity = .volume(1.4)
        let factor: Double = -2

        XCTAssertThrowsError(try quantity /= factor)
    }

    func testDividesEquals_zeroDivisor_throwsError() {
        var quantity: Quantity = .count(1.5)
        let factor: Double = 0

        XCTAssertThrowsError(try quantity /= factor)
    }
}

// MARK: - Comparable
extension QuantityTests {
    func testLessThan_sameQuantityType_success() {
        let leftCount: Quantity = .count(1)
        let rightCount: Quantity = .count(2)
        XCTAssertTrue(try leftCount < rightCount)
        XCTAssertFalse(try rightCount < leftCount)

        let leftMass: Quantity = .mass(0.3)
        let rightMass: Quantity = .mass(0.4)
        XCTAssertTrue(try leftMass < rightMass)
        XCTAssertFalse(try rightMass < leftMass)

        let leftVolume: Quantity = .volume(0.5)
        let rightVolume: Quantity = .volume(0.6)
        XCTAssertTrue(try leftVolume < rightVolume)
        XCTAssertFalse(try rightVolume < leftVolume)
    }

    func testLessThan_equalQuantities_returnsFalse() {
        let left: Quantity = .count(3)
        let right: Quantity = .count(3)
        XCTAssertFalse(try left < right)
    }

    func testLessThan_differentQuantityTypes_throwsError() {
        let left: Quantity = .count(1)
        let right: Quantity = .volume(0.5)

        XCTAssertThrowsError(try left < right)
    }

    func testEqualTo_sameQuantityType_success() {
        let leftCount: Quantity = .count(1)
        let rightCount: Quantity = .count(1)
        let differentCount: Quantity = .count(2)
        XCTAssertTrue(leftCount == rightCount)
        XCTAssertFalse(leftCount == differentCount)

        let leftMass: Quantity = .mass(0.3)
        let rightMass: Quantity = .mass(0.3)
        let differentMass: Quantity = .mass(0.4)
        XCTAssertTrue(leftMass == rightMass)
        XCTAssertFalse(leftMass == differentMass)

        let leftVolume: Quantity = .volume(0.5)
        let rightVolume: Quantity = .volume(0.5)
        let differentVolume: Quantity = .volume(0.6)
        XCTAssertTrue(leftVolume == rightVolume)
        XCTAssertFalse(leftVolume == differentVolume)
    }

    func testEqualTo_differentQuantityTypes_returnsFalse() {
        let left: Quantity = .count(1)
        let right: Quantity = .volume(0.5)

        XCTAssertFalse(left == right)
    }
}
