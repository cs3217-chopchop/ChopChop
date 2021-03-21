//
//  RecipeEditingViewModel.swift
//  ChopChop
//
//  Created by Cao Wenjie on 19/3/21.
//

import SwiftUI

class ParsingRecipeViewModel: ObservableObject {
    @Published var ingredientString = ""
    @Published var instructionString = ""

    func parseData() {
        let ingredients = RecipeParser.parseIngredientString(ingredientString: ingredientString)
        let steps = RecipeParser.parseInstructions(instructions: instructionString)
    }

}
