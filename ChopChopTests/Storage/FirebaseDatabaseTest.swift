//
//  FirebaseDatabaseTest.swift
//  ChopChopTests
//
//  Created by Cao Wenjie on 27/3/21.
//

import XCTest
import FirebaseFirestore
import FirebaseFirestoreSwift
@testable import ChopChop

class FirebaseDatabaseTest: XCTestCase {
    
    private let db = FirebaseDatabase()

    func testAddRecipe() throws {
        let steps = ["First step", "Second step", "Third step"]
        let ingredients = [
            OnlineIngredientRecord(name: "Banana", quantity: .count(2)),
            OnlineIngredientRecord(name: "salt", quantity: .volume(2, unit: .tablespoon))
        ]
        let ratings = [
            RecipeRating(userId: "1", score: .adequate),
            RecipeRating(userId: "2", score: .excellent),
            RecipeRating(userId: "3", score: .poor)
        ]
        let recipeRecord = OnlineRecipeRecord(
            name: "Test Recipe",
            creator: "12345",
            servings: 1,
            cuisine: "American",
            difficulty: Difficulty.easy,
            ingredients: ingredients,
            steps: steps,
            ratings: ratings
        )
        
        let recipeId = try db.addRecipe(recipe: recipeRecord)
        print(recipeId)
        XCTAssertNotNil(recipeId)
    }
    
    func testUpdateRecipe() throws {
        let steps = ["Change", "Second step", "Third step"]
        let ingredients = [
            OnlineIngredientRecord(name: "Apple", quantity: .count(2)),
            OnlineIngredientRecord(name: "salt", quantity: .mass(3, unit: .pound))
        ]
        let ratings = [
            RecipeRating(userId: "13", score: .adequate),
            RecipeRating(userId: "23", score: .excellent),
            RecipeRating(userId: "33", score: .great)
        ]
        let recipeRecord = OnlineRecipeRecord(
            id: "qGTfFKtU8CZleo3J5kd5",
            name: "Testing Recipe",
            creator: "12345",
            servings: 12,
            cuisine: "American",
            difficulty: Difficulty.easy,
            ingredients: ingredients,
            steps: steps,
            ratings: ratings
        )
        try db.updateRecipe(recipe: recipeRecord)
        XCTAssertTrue(true)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
