struct RecipeStepParser {

    static let delimiters = ["-", "–", "to", "or"]
    static let minUnits = ["minute[s]?", "min[s]?", "m"] // put strict ones first
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

    static let intOrDecimal = "[1-9]\\d*(\\.\\d+)?" // TODO include fraction
    static let randoShortString = "[a-z\\d\\-_\\s]{0,6}" // any <=6 chars
    static let stricterRandoShortString = optional(str: "[a-z\\d\\-_\\s]{0,5} ")

    static let defaultTime = 900

    /// Given a step, sum up all time words
    /// E.g. "cook for about 2 minutes. Turn ribs and cook until second side is golden brown, 1–2 minutes" returns 210 seconds
    static func parseTimeTaken(step: String) -> Int {
        return parseTimerDurations(step: step).map{parseToTime(timeString: $0)}.reduce(0, +)
    }

    /// Given a step, returns an array of time duration words
    /// E.g. "cook for about 2 minutes. Turn ribs and cook until second side is golden brown, 1–2 minutes" returns ["2 minutes", "1-2 minutes"]
    static func parseTimerDurations(step: String) -> [String] {
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

        let regexString = optionalRangeString +
            mostBasicTimeWithCompulsoryUnit + optional(str: randoShortString + mostBasicTimeWithCompulsoryUnit) // 1h 9 mins to 1h 10 mins
        let matched = matches(for: regexString, in: step)

        return matched
    }

    /// converts time represented in String to seconds
    /// E.g. "1 minutes" returns 60, "30 sec" returns 30
    static func parseToTime(timeString: String) -> Int {

        var allNumbersString = reducePipeSeparated(arr: digitNames.keys.map{$0})
        allNumbersString += "|" + intOrDecimal
        allNumbersString = "(" + allNumbersString + ")"
        let matchedNumbers = matches(for: allNumbersString, in: timeString)

        let allTimeUnits = minUnits + hourUnits + secondUnits
        var allTimeUnitsString = reducePipeSeparated(arr: allTimeUnits)
        allTimeUnitsString = "(" + allTimeUnitsString + ")"
        let matchedUnits = matches(for: allTimeUnitsString, in: timeString)

        if matchedNumbers.count == matchedUnits.count {
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
            // unidentifiable: e.g. cant break up word but identified "minutes", just return 15 minutes
            return defaultTime
        }

    }

    private static func parseNumber(number: String) -> Double? {
        var allNumbersString = reducePipeSeparated(arr: digitNames.keys.map{$0})
        allNumbersString += "|" + intOrDecimal
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

    /// Given a step String, scales only ingredeint quantity  by factor and returns the scaled step String
    static func scaleNumerals(step: String, scale: Double) -> String {
        // TODO copy wj's implementation of detecting ingredients
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
