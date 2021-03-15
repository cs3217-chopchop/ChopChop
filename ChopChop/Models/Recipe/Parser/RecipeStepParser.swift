struct RecipeStepParser {

    static let delimiters = ["-", "–", "to", "or"]
    static let minUnits = ["minute[s]?", "min[s]?"] // put strict ones first
    static let hourUnits = ["hour[s]?", "h"]
    static let secondUnits = ["second[s]?", "s", "sec[s]?"]
    static let digitNames = [
        "zero": 0,
        "one": 1,
        "two": 2,
        "three": 3,
        "four": 4,
        "five": 5,
        "six": 6,
        "seven": 7,
        "eight": 8,
        "nine": 9,
        "ten": 10,
        "fifteen": 15,
        "twenty": 20
    ]

    static let intOrDecimal = "[1-9]\\d*(\\.\\d+)?"
    static let randoShortString = "[a-z\\d\\-_\\s]{0,6}" // any <=10 chars
    static let stricterRandoShortString = optional(str: "[a-z\\d\\-_\\s]{0,5} ")

    static let defaultTime = 900

    /// Given a step, sum up all time words
    // convert "cook for about 2 minutes. Turn ribs and cook until second side is golden brown, 1–2 minutes" to
    // 3.5 mins * 60 = 210 seconds
    static func parseTimeTaken(step: String) -> Int {
        // 2 factors:
        // step might not contain any time words
        // user might not even want to use ML

        // worse case use default 1.0
        return parseTimerDurations(step: step).map{parseToTime(timeString: $0)}.reduce(0, +)
    }

    // convert "cook for about 2 minutes. Turn ribs and cook until second side is golden brown, 1–2 minutes" to
    // ["2 minutes", "1-2 minutes"]
    static func parseTimerDurations(step: String) -> [String] {
        // 1–2 minutes
        // 1 to 2 minutes

        var allDelimitersString = reducePipeSeparated(arr: delimiters)
        let allTimeUnits = minUnits + hourUnits + secondUnits
        var allTimeUnitsString = reducePipeSeparated(arr: allTimeUnits)
        var allNumbersString = reducePipeSeparated(arr: digitNames.keys.map{$0})
        allNumbersString += "|" + intOrDecimal // zero|one|...|[0-9]

        allDelimitersString = "(" + allDelimitersString + ")"
        allTimeUnitsString = "(" + allTimeUnitsString + ")"
        allNumbersString = "(" + allNumbersString + ")"

        let mostBasicTimeWithOptionalUnit = allNumbersString + optional(str: stricterRandoShortString + allTimeUnitsString) // 30 mins or 30
        let mostBasicTimeWithCompulsoryUnit = allNumbersString + stricterRandoShortString + allTimeUnitsString
        let optionalRangeString = optional(str: mostBasicTimeWithOptionalUnit + optional(str: randoShortString + mostBasicTimeWithOptionalUnit) + randoShortString + allDelimitersString + randoShortString) // 1h 30mins to

        // less than 10 chars exist between the number and unit
        let regexString = optionalRangeString +
            mostBasicTimeWithCompulsoryUnit + optional(str: randoShortString + mostBasicTimeWithCompulsoryUnit) // 1h 9 mins to 1h 10 mins
        let matched = matches(for: regexString, in: step)
        print(matched)

        return matched
    }

    // convert to time in seconds
    // "1 minutes" to 60, "30 sec" to 30, etc
    static func parseToTime(timeString: String) -> Int {

        var allNumbersString = reducePipeSeparated(arr: digitNames.keys.map{$0})
        allNumbersString += "|" + intOrDecimal // zero|one|...|[0-9]
        allNumbersString = "(" + allNumbersString + ")"
        let matchedNumbers = matches(for: allNumbersString, in: timeString)

        let allTimeUnits = minUnits + hourUnits + secondUnits
        var allTimeUnitsString = reducePipeSeparated(arr: allTimeUnits)
        allTimeUnitsString = "(" + allTimeUnitsString + ")"
        let matchedUnits = matches(for: allTimeUnitsString, in: timeString)

        if matchedNumbers.count == matchedUnits.count {
            // 2025 minutes
            // about 1 hour 10 minutes
            // 1h 20 min to 1h 30 min


            // 1h 20 min to 1h 30 min to [3600, 120, 3600, 180]
            var scaledValues: [Double] = []
            for i in 0..<matchedNumbers.count {
                guard let scale = parseTimeUnit(unit: matchedUnits[i]), let number = parseNumber(number: matchedNumbers[i]) else {
                    assertionFailure()
                    return defaultTime
                }
                scaledValues.append(number * scale)
            }

            let isRanged = timeString ~= ".*" + "(" + reducePipeSeparated(arr: delimiters) + ")" + ".*" && matchedNumbers.count > 1
            if isRanged {
                let firstNumber = scaledValues[0..<(matchedNumbers.count/2)].reduce(0, +)
                let secondNumber = scaledValues[(matchedNumbers.count/2)...].reduce(0, +)
                return Int((firstNumber + secondNumber) / 2)
            } else {
                let number = scaledValues[0..<(matchedNumbers.count)].reduce(0, +)
                return Int(number)
            }

        } else if matchedNumbers.count == 2 && matchedUnits.count == 1 {
            guard let scale = parseTimeUnit(unit: matchedUnits[0]), let firstNumber = parseNumber(number: matchedNumbers[0]), let secondNumber = parseNumber(number: matchedNumbers[1]) else {
                assertionFailure()
                return defaultTime
            }
            return Int(((firstNumber + secondNumber) / 2) * scale)

        } else {
            // unidentifiable
            // eg if cant break up word but identified "minutes", just return 15 minutes
            return defaultTime
        }

    }

    private static func parseNumber(number: String) -> Double? {
        var allNumbersString = reducePipeSeparated(arr: digitNames.keys.map{$0})
        allNumbersString += "|" + intOrDecimal // zero|one|...|[0-9]
        guard number ~= allNumbersString else {
            return nil
        }

        guard let str = digitNames[number] else {
            return Double(number)
        }
        return Double(str)
    }

    /// Convert time unit to scale
    private static func parseTimeUnit(unit: String) -> Double? {
        if unit ~= reducePipeSeparated(arr: minUnits) { // must start with minutes first cos *.s will conflict
            return 60
        } else if unit ~= reducePipeSeparated(arr: hourUnits) {
            return 3600
        } else if unit ~= reducePipeSeparated(arr: secondUnits) {
            return 1
        } else {
            return nil
        }
    }

    /// Given a step String, scales all numbers by factor (including ingredient quantity, time) and returns the scaled step String
    static func scaleNumerals(step: String, scale: Double) -> String {
        guard scale > 0 else {
            assertionFailure("Should be positive magnitude")
            return step
        }
        return step
    }

    private static func reducePipeSeparated(arr: [String]) -> String {
        arr.joined(separator: "|")
    }

    private static func optional(str: String) -> String {
        "(" + str + ")?"
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
