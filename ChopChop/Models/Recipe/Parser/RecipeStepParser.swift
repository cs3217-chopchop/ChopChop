import Foundation

class RecipeStepParser {
//    let machineLearningStub: MachineLearningStub

    /// Given a step, sum up all time words
    // convert "cook for about 2 minutes. Turn ribs and cook until second side is golden brown, 1–2 minutes" to
    // 3.5 mins * 60 = 210 seconds
    func parseTimeTaken(step: String) -> Double {
        // 2 factors:
        // step might not contain any time words
        // user might not even want to use ML

        // worse case use default 1.0
        return parseTimerDurations(step: step).map{parseToTime(timeString: $0)}.reduce(0, +)
    }

    // convert "cook for about 2 minutes. Turn ribs and cook until second side is golden brown, 1–2 minutes" to
    // ["2 minutes", "1.5 minutes"]
    func parseTimerDurations(step: String) -> [String] {
//        [(String, CountdownTimer)]
        return []
    }

    // convert "1 minutes" to 60, "30 sec" to 30, etc
    func parseToTime(timeString: String) -> Double {
        // 20 - 25 mins
        // 2025 minutes
//        let time_indicator_regex = '(min|hour)'

        // "50 minutes per pound"
        // "15 more minutes"
        // "15 minutes"
        // 
        
        return 1.0
    }

    /// Given a step String, scales all numbers by factor (including ingredient quantity, time) and returns the scaled step String
    func scaleNumerals(step: String, scale: Double) -> String {
        guard scale > 0 else {
            assertionFailure("Should be positive magnitude")
            return step
        }
        return step
    }
}


