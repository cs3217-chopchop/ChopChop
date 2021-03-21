// swiftlint:disable line_length

import XCTest

@testable import ChopChop

class MassUnitTests: XCTestCase {
    let testValue: Double = 1.234
}

// MARK: - Convert
extension MassUnitTests {
    func testConvert() {
        for currentUnit in MassUnit.allCases {
            for newUnit in MassUnit.allCases {
                let convertedValue = MassUnit.convert(testValue, from: currentUnit, to: newUnit)
                let expectedValue = testValue * currentUnit.ratioToKilogram / newUnit.ratioToKilogram

                XCTAssertEqual(convertedValue, expectedValue)
            }
        }
    }

    func testConvertToVolume() {
        for massUnit in MassUnit.allCases {
            for volumeUnit in VolumeUnit.allCases {
                let convertedValue = MassUnit.convertToVolume(testValue, from: massUnit, to: volumeUnit)
                let expectedValue = testValue * massUnit.ratioToKilogram * QuantityType.massToVolumeBaseRatio / volumeUnit.ratioToLiter

                XCTAssertEqual(convertedValue, expectedValue)
            }
        }
    }
}
