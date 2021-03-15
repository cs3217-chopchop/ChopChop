import XCTest
@testable import ChopChop

class RecipeStepParserTests: XCTestCase {

    // https://www.allrecipes.com/
    func testParseTimeTaken() {
        let timeTaken = RecipeStepParser.parseTimeTaken(step: "cook for about 2 minutes. Turn ribs and cook until second side is golden brown, 1–2 minutes")
        XCTAssertEqual(timeTaken, 210)
    }

    func testParseTimeTaken_closeTogether() {
        let timeTaken = RecipeStepParser.parseTimeTaken(step: "Select high pressure according to manufacturer's instructions; set timer for 2 minutes. Allow 10 minutes for pressure to build.")
        XCTAssertEqual(timeTaken, 720)
    }

    func testParseTimeTaken_manyTimers() {
        let timeTaken = RecipeStepParser.parseTimeTaken(step: "Add flour, milk, eggs, and melted butter to a blender and process until smooth, 1 to 2 minutes. Set batter aside for at least 20 minutes. Loosen crepe carefully from the pan using a spatula and gently flip to brown the other side, 1 to 2 minutes more. ")
        XCTAssertEqual(timeTaken, 1380)
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

    func testParseToTime() {
        let timeTaken = RecipeStepParser.parseToTime(timeString: "1–2 minutes")
        XCTAssertEqual(timeTaken, 90)
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

    func testParseToTime_failure() {
        let timeTaken = RecipeStepParser.parseToTime(timeString: "1 1/2 hours")
        XCTAssertEqual(timeTaken, 900)
    }

}
