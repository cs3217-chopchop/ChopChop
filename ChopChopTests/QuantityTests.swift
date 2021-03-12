import XCTest
@testable import ChopChop

class QuantityTests: XCTestCase {
    func testEquals_sameUnits_success() throws {
        XCTAssertEqual(Count(1), Count(1))
        XCTAssertEqual(Mass(2, .kilograms), Mass(2, .kilograms))
        XCTAssertEqual(Volume(2, .litres), Volume(2, .litres))
    }

    func testEquals_differentUnits_success() throws {
        XCTAssertEqual(Mass(2, .kilograms), Mass(2_000, .grams))
        XCTAssertEqual(Volume(2, .litres), Volume(2_000, .millilitres))
    }

    func testAdd_sameUnits_success() throws {
        XCTAssertEqual(Mass(2, .kilograms) + Mass(500, .grams), Mass(2.5, .kilograms))
        XCTAssertEqual(Volume(3, .litres) + Volume(250, .millilitres), Volume(3.25, .litres))
    }

    func testSubtract_sameUnits_success() throws {
        XCTAssertEqual(Mass(2, .kilograms) - Mass(500, .grams), Mass(1.5, .kilograms))
        XCTAssertEqual(Volume(3, .litres) - Volume(250, .millilitres), Volume(2.75, .litres))
    }

    func testString_success() throws {
        XCTAssertEqual("\(Mass(2, .kilograms))", "2 kg")
        XCTAssertEqual("\(Mass(2.1, .kilograms))", "2.1 kg")
        XCTAssertEqual("\(Mass(2.13, .kilograms))", "2.13 kg")

        XCTAssertEqual("\(Mass(0.9, .kilograms))", "900 g")
        XCTAssertEqual("\(Mass(0.9, .kilograms) + Mass(100, .grams))", "1 kg")

        XCTAssertEqual("\(Volume(1, .litre))", "1 L")
        XCTAssertEqual("\(Volume(1.2, .litre))", "1.2 L")
        XCTAssertEqual("\(Volume(1.23, .litre))", "1.23 L")

        XCTAssertEqual("\(Volume(0.9, .litres))", "900 ml")
        XCTAssertEqual("\(Volume(0.9, .litres) + Volume(100, .millilitres))", "1 L")
    }
}
