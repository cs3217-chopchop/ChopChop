//
//  RecipeFormError.swift
//  ChopChop
//
//  Created by Cao Wenjie on 21/3/21.
//

enum RecipeFormError: Error {
    case emptyName
    case emptyServing
    case emptyStep
    case emptyStepDescription
    case emptyIngredient
    case emptyIngredientQuantity
    case emptyIngredientUnit
    case emptyIngredientDescription
    case invalidServing
}
