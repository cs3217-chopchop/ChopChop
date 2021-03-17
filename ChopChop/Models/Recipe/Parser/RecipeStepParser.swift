struct RecipeStepParser {

    static let delimiters = ["-", "–", "to", "or"]
    static let minUnits = ["minute[s]?", "min[s]?", "m"] // put strict ones first
    static let hourUnits = ["hour[s]?", "h"]
    static let secondUnits = ["second[s]?", "sec[s]?", "s"]
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
        "twenty": 20,
        "half": 0.5
    ]

    static let intOrDecimal = "\\d+" + optional(str: "(\\.|/)\\d+")
    static let randoShortString = "[a-z\\d\\-_\\s]{0,6}" // any <=6 chars
    static let stricterRandoShortString = optional(str: "[a-z\\d\\-_\\s]{0,5} ")
    static let specialAndDelimiter = " (and|&) "

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
        allNumbersString += optional(str: specialAndDelimiter + allNumbersString) // 1 and a half min

        allDelimitersString = "(" + allDelimitersString + ")"
        allTimeUnitsString = "(" + allTimeUnitsString + ")"
        allNumbersString = "(" + allNumbersString + ")"

        let mostBasicTimeWithOptionalUnit = allNumbersString + optional(str: stricterRandoShortString + allTimeUnitsString) // 30 mins or 30
        let mostBasicTimeWithCompulsoryUnit = allNumbersString + stricterRandoShortString + allTimeUnitsString
        let optionalRangeString = optional(str: mostBasicTimeWithOptionalUnit + optional(str: randoShortString + mostBasicTimeWithOptionalUnit) + randoShortString + allDelimitersString + randoShortString) // 1h 30mins to

        let regexString = optionalRangeString +
            mostBasicTimeWithCompulsoryUnit + optional(str: randoShortString + mostBasicTimeWithCompulsoryUnit) // 1h 9 mins to 1h 10 mins
        let matched = matches(for: regexString, in: step)
        let trimmed = matched.map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}

        return trimmed
    }

    /// converts time represented in String to seconds
    /// E.g. "1 minutes" returns 60, "30 sec" returns 30
    static func parseToTime(timeString: String) -> Int {
        var allNumbersString = reducePipeSeparated(arr: digitNames.keys.map{$0})
        allNumbersString += "|" + intOrDecimal
        allNumbersString = "(" + allNumbersString + ")" // (1|2|3...one|two|...)
        let matchedNumbers = matchesWithIndex(for: allNumbersString, in: timeString)

        let allTimeUnits = minUnits + hourUnits + secondUnits
        var allTimeUnitsString = reducePipeSeparated(arr: allTimeUnits)
        allTimeUnitsString = "(" + allTimeUnitsString + ")"
        var matchedUnits = matchesWithIndex(for: allTimeUnitsString, in: timeString) // (minutes|seconds|..)

        // there should be no overlap between matchedNumbers and matchedUnits
        let matchedNumberIndexRanges = matchedNumbers.map{($0.1, $0.1 + $0.0.count)}
        matchedUnits = matchedUnits.filter{ (unit) -> Bool in
            // the unit's start must be greater than each number's end
            // OR
            // the unit's end much be lesser than each number's start
            matchedNumberIndexRanges.allSatisfy{unit.1 >= $0.1 || unit.1 + unit.0.count < $0.0}}

        // 1h 20 min to 1h 30 min to [3600, 120, 3600, 180]
        var scaledValues: [Double] = []
        for i in 0..<matchedNumbers.count {
            // index of matched unit just exceeds that of number e.g. 1 1/2 hour
            guard let nearestTimeUnitForNumber = (matchedUnits.first{$0.1 > matchedNumbers[i].1}) else {
                assertionFailure()
                return defaultTime
            }
            guard let scale = parseTimeUnit(unit: nearestTimeUnitForNumber.0), let number = parseNumber(number: matchedNumbers[i].0) else {
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

    }

    private static func parseNumber(number: String) -> Double? {
        var allNumbersString = reducePipeSeparated(arr: digitNames.keys.map{$0})
        allNumbersString += "|" + intOrDecimal
        guard number ~= allNumbersString else {
            return nil
        }

        if let str = digitNames[number] {
            return str
        }

        if number ~= "\\d+/\\d+" {
            let fraction = number.split(separator: "/")
            guard let numerator = Double(fraction[0]), let denominator = Double(fraction[1]) else {
                assertionFailure()
                return Double(defaultTime)
            }
            return numerator / denominator
        }

        // regular Int or decimal
        return Double(number)

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

    private static func reducePipeSeparated(arr: [String]) -> String {
        arr.joined(separator: "|")
    }

    private static func optional(str: String) -> String {
        "(" + str + ")?"
    }
}
