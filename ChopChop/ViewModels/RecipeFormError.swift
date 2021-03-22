//
//  RecipeFormError.swift
//  ChopChop
//
//  Created by Cao Wenjie on 21/3/21.
//

enum RecipeFormError: String, Error {
    case emptyName = "Recipe name cannot be empty."
    case emptyServing = "Recipe serving cannot be empty."
    case emptyStep = "Recipe cannot have no steps."
    case emptyStepDescription = "Recipe step description cannot be empty."
    case emptyIngredient = "Recipe cannot have no ingredients."
    case emptyIngredientQuantity = """
        Recipe ingredient amount cannot be empty. If ingredient has no associated amount, input 0.
    """
    case invalidIngredientQuantity = "Recipe ingredient amount is not a valid number."
    case emptyIngredientDescription = "Recipe ingredient name cannot be empty"
    case invalidServing = "Recipe serving is not a valid number."
}
