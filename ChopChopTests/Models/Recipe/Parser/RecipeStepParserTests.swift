import XCTest
@testable import ChopChop

class RecipeStepParserTests: XCTestCase {

    // https://www.allrecipes.com/
    func testParseTimeTaken() {
        let timeTaken = RecipeStepParser.parseTimeTaken(step: "cook for about 5 min 40 seconds. Turn ribs and cook until second side is golden brown, 1–2 minutes")
        XCTAssertEqual(timeTaken, 430)
    }

    func testParseTimeTaken_closeTogether() {
        let timeTaken = RecipeStepParser.parseTimeTaken(step: "Select high pressure according to manufacturer's instructions; set timer for 2 minutes. Allow 10 minutes for pressure to build.")
        XCTAssertEqual(timeTaken, 720)
    }

    func testParseTimeTaken_manyTimers() {
        let timeTaken = RecipeStepParser.parseTimeTaken(step: "Add flour, milk, eggs, and melted butter to a blender and process until smooth, 5m 40s. Set batter aside for at least 20 minutes. Loosen crepe carefully from the pan using a spatula and gently flip to brown the other side, 1 to 2 minutes more. ")
        XCTAssertEqual(timeTaken, 1630)
    }

    func testParseTimeDurations() {
        let durations = RecipeStepParser.parseTimerDurations(step: "cook for about 2 minutes. Turn ribs and cook until second side is golden brown, 1 or two minutes")
        XCTAssertEqual(durations, ["2 minutes", "1 or two minutes"])
    }

    func testParseTimeDurations_closeTogether() {
        let durations = RecipeStepParser.parseTimerDurations(step: "cook for about 2 minutes. For 1 minutes, turn ribs.")
        XCTAssertEqual(durations, ["2 minutes", "1 minutes"])
    }

    func testParseTimeDurations_failure() {
        let durations = RecipeStepParser.parseTimerDurations(step: "Turn 5 ribs and cook until second side is golden brown mins")
        XCTAssertEqual(durations, [])
    }

    func testParseToTime_decimal() {
        let timeTaken = RecipeStepParser.parseToTime(timeString: "2.5 minutes")
        XCTAssertEqual(timeTaken, 150)
    }

    func testParseToTime_fraction() {
        let timeTaken = RecipeStepParser.parseToTime(timeString: "1 1/2 hours")
        XCTAssertEqual(timeTaken, 5400)
    }

    func testParseToTime_complexfraction() {
        let timeTaken = RecipeStepParser.parseToTime(timeString: "2 and a half minute")
        XCTAssertEqual(timeTaken, 150)
    }


    func testParseToTime_withRangeNoSpace() {
        let timeTaken = RecipeStepParser.parseToTime(timeString: "20-25mins")
        XCTAssertEqual(timeTaken, 1350)
    }

    func testParseToTime_wordBetween() {
        let timeTaken = RecipeStepParser.parseToTime(timeString: "15 more minutes")
        XCTAssertEqual(timeTaken, 900)
    }

    func testParseToTime_twoUnits() {
        let timeTaken = RecipeStepParser.parseToTime(timeString: "1 hour 10 minutes")
        XCTAssertEqual(timeTaken, 4200)
    }

    func testParseToTime_twoUnitsWithRange() {
        let timeTaken = RecipeStepParser.parseToTime(timeString: "1h 20 min to 1h 30 min")
        XCTAssertEqual(timeTaken, 5100)
    }

    func testParseToTime_numberWord() {
        let timeTaken = RecipeStepParser.parseToTime(timeString: "five to 10 minutes")
        XCTAssertEqual(timeTaken, 450)
    }

}


// 20 - 25 mins
// 2025 minutes
// "50 minutes per pound"
// "15 more minutes"
// "15 minutes"
// 2 to 3 hours
// 10 to 15 minutes
// 2 or 3 more minutes
// 20 seconds
// about 1 hour 10 minutes
// 1 1/2 hours
// -
// 2 or 3 minutes
// 45 seconds
// 45 second
// 1h 20 min to 1h 30 min
// 45-50 minutes
// 10 min
// five to 10 minutes
// no spaces
// 10mins
// 1 hour
// 20 sec
// 10-15 min
// (abt 20 mins)
// 1 and a half minute
