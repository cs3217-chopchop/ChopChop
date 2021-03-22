import XCTest
@testable import ChopChop

class RecipeStepParserTests: XCTestCase {

    func testParseTimeTaken() {
        let timeTaken = RecipeStepParser.parseTimeTaken(step: """
cook for about 5 min 40 seconds. \
Turn ribs and cook until second side is golden brown, 1–2 minutes
""")
        XCTAssertEqual(timeTaken, 430)
    }

    func testParseTimeTaken_closeTogether() {
        let timeTaken = RecipeStepParser.parseTimeTaken(step: """
Select high pressure according to manufacturer's instructions; set timer for 2 1/3 h. \
Allow 10 minutes for pressure to build.
""")
        XCTAssertEqual(timeTaken, 9_000)
    }

    func testParseTimeTaken_manyTimers() {
        let timeTaken = RecipeStepParser.parseTimeTaken(step:
                                                            """
 Add flour, milk, eggs, and melted butter to a blender and process until smooth, 5m 40s. \
 Set batter aside for at least 20 minutes. Loosen crepe carefully from the pan using a spatula and \
 gently flip to brown the other side, 0.5 to 2 minutes more.
 """)
        XCTAssertEqual(timeTaken, 1_615)
    }

    func testParseTimeTaken_negativeZeroMinutes_ignoreNegativeSign() {
        let timeTaken = RecipeStepParser.parseTimeTaken(step:
                                                            """
 Add flour, milk, eggs, and melted butter to a blender and process until smooth, 5m -40s. \
 Set batter aside for at least 0 minutes. Loosen crepe carefully from the pan using a spatula and \
 gently flip to brown the other side, -1 to 2 minutes more.
 """)
        XCTAssertEqual(timeTaken, 390)
    }

    func testParseTimeTaken_moreThanHours() {
        let timeTaken = RecipeStepParser.parseTimeTaken(step:
                                                            """
 Add flour, milk, eggs, and melted butter to a blender and process until smooth, 1 day 5hours. \
 for at least 5 hours 40 minutes and 30 seconds, set batter aside. \
 Loosen crepe carefully from the pan using a spatula and \
 gently flip to brown the other side, 3.8m more.
 """)
        XCTAssertEqual(timeTaken, 38_658)
    }

    func testParseTimeTaken_noTimeMention() {
        let timeTaken = RecipeStepParser.parseTimeTaken(step: "Preheat an oven to 425 degrees F (220 degrees C).")
        XCTAssertEqual(timeTaken, 0)
    }

    func testParseTimeTaken_notStep_parserNotPerfect() {
        let timeTaken = RecipeStepParser.parseTimeTaken(step: """
            5 calories; protein 0.2g; carbohydrates 0.9g; fat 0.2g; sodium 184.8mg
            """)
        XCTAssertEqual(timeTaken, 11_088)
    }

    func testParseTimeDurations() {
        let durations = RecipeStepParser.parseTimerDurations(step: """
cook for about 2 minutes. \
Turn ribs and cook until second side is golden brown, 1 or two minutes
""")
        XCTAssertEqual(durations, ["2 minutes", "1 or two minutes"])
    }

    func testParseTimeDurations_closeTogether() {
        let durations = RecipeStepParser.parseTimerDurations(step:
                                                                "cook for about 2 minutes. For 1 minutes, turn ribs.")
        XCTAssertEqual(durations, ["2 minutes", "1 minutes"])
    }

    func testParseTimeDurations_fraction() {
        let durations = RecipeStepParser.parseTimerDurations(step: "set timer for 2 1/3 h")
        XCTAssertEqual(durations, ["2 1/3 h"])
    }

    func testParseTimeDurations_empty() {
        let durations = RecipeStepParser.parseTimerDurations(step: """
            Turn 5 ribs and cook until second side is golden brown mins
        """)
        XCTAssertEqual(durations, [])
    }

    func testParseToTime_decimal() {
        let timeTaken = RecipeStepParser.parseToTime(timeString: "2.5 minutes")
        XCTAssertEqual(timeTaken, 150)
    }

    func testParseToTime_fraction() {
        let timeTaken = RecipeStepParser.parseToTime(timeString: "1 1/2 hours")
        XCTAssertEqual(timeTaken, 5_400)
    }

    func testParseToTime_unrecognisedFraction() {
        let timeTaken = RecipeStepParser.parseToTime(timeString: "½ m")
        XCTAssertEqual(timeTaken, 0)
    }

    func testParseToTime_complexfraction() {
        let timeTaken = RecipeStepParser.parseToTime(timeString: "2 and a half minute")
        XCTAssertEqual(timeTaken, 150)
    }

    func testParseToTime_withRangeNoSpace() {
        let timeTaken = RecipeStepParser.parseToTime(timeString: "20-25mins")
        XCTAssertEqual(timeTaken, 1_350)
    }

    func testParseToTime_wordBetween() {
        let timeTaken = RecipeStepParser.parseToTime(timeString: "15 more minutes")
        XCTAssertEqual(timeTaken, 900)
    }

    func testParseToTime_twoUnits() {
        let timeTaken = RecipeStepParser.parseToTime(timeString: "1 hour 10 minutes")
        XCTAssertEqual(timeTaken, 4_200)
    }

    func testParseToTime_twoUnitsWithRange() {
        let timeTaken = RecipeStepParser.parseToTime(timeString: "1h 20 min to 1h 30 min")
        XCTAssertEqual(timeTaken, 5_100)
    }

    func testParseToTime_numberWord() {
        let timeTaken = RecipeStepParser.parseToTime(timeString: "five to 10 minutes")
        XCTAssertEqual(timeTaken, 450)
    }

    func testParseToTime_negativeNumber_takeFirst() {
        let timeTaken = RecipeStepParser.parseToTime(timeString: "5h -40min")
        XCTAssertEqual(timeTaken, 18_000)
    }

    func testParseToTime_noUnits() {
        let timeTaken = RecipeStepParser.parseToTime(timeString: "500")
        XCTAssertEqual(timeTaken, 0)
    }

    func testParseToTime_differentUnits() {
        let timeTaken = RecipeStepParser.parseToTime(timeString: "30m to 1h 2 min")
        XCTAssertEqual(timeTaken, 2_760)
    }

}
