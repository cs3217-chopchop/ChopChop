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

    private let firebase = FirebaseDatabase()
    private let db = Firestore.firestore()

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

        let recipeRecord2 = OnlineRecipeRecord(
            name: "Testing Recipe",
            creator: "12345",
            servings: 1,
            cuisine: "American",
            difficulty: Difficulty.easy,
            ingredients: ingredients,
            steps: steps,
            ratings: ratings
        )

        let recipeId = try firebase.addRecipe(recipe: recipeRecord)
        let testAdd = self.expectation(description: "Saving recipe")
        db.collection("recipe").document(recipeId).getDocument { document, _  in
            guard let documentObtained = document else {
                XCTFail("Document not found")
                return
            }

            let data = try? documentObtained.data(as: OnlineRecipeRecord.self)
            guard let recipe = data else {
                XCTFail("recipe data invalid")
                return
            }
            XCTAssertEqual(recipe, recipeRecord2)
            testAdd.fulfill()
        }
        self.waitForExpectations(timeout: 15, handler: nil)
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
        try firebase.updateRecipeDetails(recipe: recipeRecord)
        XCTAssertTrue(true)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
