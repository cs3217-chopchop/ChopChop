class RecipeStepParser {
//    let machineLearningStub: MachineLearningStub

    /// Given a step, sum up all time words
    func parseTimeTaken(step: String) -> Double {
        // 2 factors:
        // step might not contain any time words
        // user might not even want to use ML


        // worse case use default 1.0
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
