// swiftlint:disable line_length

import XCTest

@testable import ChopChop

class VolumeUnitTests: XCTestCase {
    let testValue: Double = 1.234
}

// MARK: - Convert
extension VolumeUnitTests {
    func testConvert() {
        for currentUnit in VolumeUnit.allCases {
            for newUnit in VolumeUnit.allCases {
                let convertedValue = VolumeUnit.convert(testValue, from: currentUnit, to: newUnit)
                let expectedValue = testValue * currentUnit.ratioToLiter / newUnit.ratioToLiter

                XCTAssertEqual(convertedValue, expectedValue)
            }
        }
    }

    func testConvertToVolume() {
        for volumeUnit in VolumeUnit.allCases {
            for massUnit in MassUnit.allCases {
                let convertedValue = VolumeUnit.convertToMass(testValue, from: volumeUnit, to: massUnit)
                let expectedValue = (testValue * volumeUnit.ratioToLiter / QuantityUnit.massToVolumeBaseRatio) / massUnit.ratioToKilogram

                XCTAssertEqual(convertedValue, expectedValue)
            }
        }
    }
}
