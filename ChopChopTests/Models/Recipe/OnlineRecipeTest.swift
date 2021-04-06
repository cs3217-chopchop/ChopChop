//
//  OnlineRecipeTest.swift
//  ChopChopTests
//
//  Created by Cao Wenjie on 6/4/21.
//

import XCTest
@testable import ChopChop

class OnlineRecipeTest: XCTestCase {

    func testDefaultInitializer_allFieldsFilled_success() throws {
        let steps = ["First step", "Second step", "Third Step"]
        let stepNodes = try steps.map({ RecipeStepNode(try RecipeStep(content: $0)) })
        let stepEdges = [
            Edge<RecipeStepNode>(source: stepNodes[0], destination: stepNodes[1]),
            Edge<RecipeStepNode>(source: stepNodes[1], destination: stepNodes[2])
        ].compactMap({ $0 })
        let ingredients = [
            try RecipeIngredient(name: "Apple", quantity: Quantity(.count, value: 2)),
            try RecipeIngredient(name: "Sugar", quantity: Quantity(.volume(.tablespoon), value: 2))
        ]
        let ratings = [
            RecipeRating(userId: "user1", score: .poor),
            RecipeRating(userId: "user2", score: .great)
        ]
        let currentDate = Date()
        let stepGraph = try RecipeStepGraph(nodes: stepNodes, edges: stepEdges)
        let onlineRecipe = try OnlineRecipe(
            id: "TestId",
            userId: "TestUserId",
            name: "Banana Cupcake",
            servings: 2,
            difficulty: .medium,
            cuisine: "Chinese",
            steps: steps,
            stepGraph: stepGraph,
            ingredients: ingredients,
            ratings: ratings,
            created: currentDate
        )

        XCTAssertEqual(onlineRecipe.id, "TestId")
        XCTAssertEqual(onlineRecipe.userId, "TestUserId")
        XCTAssertEqual(onlineRecipe.name, "Banana Cupcake")
        XCTAssertEqual(onlineRecipe.servings, 2)
        XCTAssertEqual(onlineRecipe.difficulty, .medium)
        XCTAssertEqual(onlineRecipe.cuisine, "Chinese")
        XCTAssertEqual(onlineRecipe.steps, steps)
        XCTAssertEqual(onlineRecipe.stepGraph, stepGraph)
        XCTAssertEqual(onlineRecipe.ingredients, ingredients)
        XCTAssertEqual(onlineRecipe.ratings, ratings)
        XCTAssertEqual(onlineRecipe.created, currentDate)
    }

    func testDefaultInitializer_optionalFieldsNotFilled_success() throws {
        let steps = ["First step", "Second step", "Third Step"]
        let stepNodes = try steps.map({ RecipeStepNode(try RecipeStep(content: $0)) })
        let stepEdges = [
            Edge<RecipeStepNode>(source: stepNodes[0], destination: stepNodes[1]),
            Edge<RecipeStepNode>(source: stepNodes[1], destination: stepNodes[2])
        ].compactMap({ $0 })
        let ingredients = [
            try RecipeIngredient(name: "Apple", quantity: Quantity(.count, value: 2)),
            try RecipeIngredient(name: "Sugar", quantity: Quantity(.volume(.tablespoon), value: 2))
        ]
        let ratings = [
            RecipeRating(userId: "user1", score: .poor),
            RecipeRating(userId: "user2", score: .great)
        ]
        let currentDate = Date()
        let stepGraph = try RecipeStepGraph(nodes: stepNodes, edges: stepEdges)
        let onlineRecipe = try OnlineRecipe(
            id: "TestId",
            userId: "TestUserId",
            name: "Banana Cupcake",
            servings: 2,
            difficulty: nil,
            cuisine: nil,
            steps: steps,
            stepGraph: stepGraph,
            ingredients: ingredients,
            ratings: ratings,
            created: currentDate
        )

        XCTAssertEqual(onlineRecipe.id, "TestId")
        XCTAssertEqual(onlineRecipe.userId, "TestUserId")
        XCTAssertEqual(onlineRecipe.name, "Banana Cupcake")
        XCTAssertEqual(onlineRecipe.servings, 2)
        XCTAssertNil(onlineRecipe.difficulty)
        XCTAssertNil(onlineRecipe.cuisine)
        XCTAssertEqual(onlineRecipe.steps, steps)
        XCTAssertEqual(onlineRecipe.stepGraph, stepGraph)
        XCTAssertEqual(onlineRecipe.ingredients, ingredients)
        XCTAssertEqual(onlineRecipe.ratings, ratings)
        XCTAssertEqual(onlineRecipe.created, currentDate)
    }

    func testDefaultInitializer_emptyName_fail() throws {

        let steps = ["First step", "Second step", "Third Step"]
        let stepNodes = try steps.map({ RecipeStepNode(try RecipeStep(content: $0)) })
        let stepEdges = [
            Edge<RecipeStepNode>(source: stepNodes[0], destination: stepNodes[1]),
            Edge<RecipeStepNode>(source: stepNodes[1], destination: stepNodes[2])
        ].compactMap({ $0 })
        let ingredients = [
            try RecipeIngredient(name: "Apple", quantity: Quantity(.count, value: 2)),
            try RecipeIngredient(name: "Sugar", quantity: Quantity(.volume(.tablespoon), value: 2))
        ]
        let ratings = [
            RecipeRating(userId: "user1", score: .poor),
            RecipeRating(userId: "user2", score: .great)
        ]
        let currentDate = Date()
        let stepGraph = try RecipeStepGraph(nodes: stepNodes, edges: stepEdges)

        XCTAssertThrowsError(try OnlineRecipe(
            id: "TestId",
            userId: "TestUserId",
            name: "",
            servings: 2,
            difficulty: .medium,
            cuisine: "Chinese",
            steps: steps,
            stepGraph: stepGraph,
            ingredients: ingredients,
            ratings: ratings,
            created: currentDate
        ))
    }

    func testDefaultInitializer_servingBelowZero_fail() throws {
        let steps = ["First step", "Second step", "Third Step"]
        let stepNodes = try steps.map({ RecipeStepNode(try RecipeStep(content: $0)) })
        let stepEdges = [
            Edge<RecipeStepNode>(source: stepNodes[0], destination: stepNodes[1]),
            Edge<RecipeStepNode>(source: stepNodes[1], destination: stepNodes[2])
        ].compactMap({ $0 })
        let ingredients = [
            try RecipeIngredient(name: "Apple", quantity: Quantity(.count, value: 2)),
            try RecipeIngredient(name: "Sugar", quantity: Quantity(.volume(.tablespoon), value: 2))
        ]
        let ratings = [
            RecipeRating(userId: "user1", score: .poor),
            RecipeRating(userId: "user2", score: .great)
        ]
        let currentDate = Date()
        let stepGraph = try RecipeStepGraph(nodes: stepNodes, edges: stepEdges)

        XCTAssertThrowsError(try OnlineRecipe(
            id: "TestId",
            userId: "TestUserId",
            name: "Banana Cupcake",
            servings: -1,
            difficulty: .medium,
            cuisine: "Chinese",
            steps: steps,
            stepGraph: stepGraph,
            ingredients: ingredients,
            ratings: ratings,
            created: currentDate
        ))
    }

    func testConvenienceInitializer_success() throws {
        let steps = ["First step", "Second step", "Third Step"]
        let stepNodes = try steps.map({ RecipeStepNode(try RecipeStep(content: $0)) })
        let stepEdges = [
            Edge<RecipeStepNode>(source: stepNodes[0], destination: stepNodes[1]),
            Edge<RecipeStepNode>(source: stepNodes[1], destination: stepNodes[2])
        ].compactMap({ $0 })

        let stepGraph = try RecipeStepGraph(nodes: stepNodes, edges: stepEdges)
        let stepEdgeRecords = [
            OnlineStepEdgeRecord(sourceStep: steps[0], destinationStep: steps[1]),
            OnlineStepEdgeRecord(sourceStep: steps[1], destinationStep: steps[2])
        ]
        let ingredientRecord = [
            OnlineIngredientRecord(name: "Apple", quantity: .count(2)),
            OnlineIngredientRecord(name: "Sugar", quantity: .volume(2, unit: .tablespoon))
        ]
        let ingredients = [
            try RecipeIngredient(name: "Apple", quantity: Quantity(.count, value: 2)),
            try RecipeIngredient(name: "Sugar", quantity: Quantity(.volume(.tablespoon), value: 2))
        ]
        let ratings = [
            RecipeRating(userId: "user1", score: .poor),
            RecipeRating(userId: "user2", score: .great)
        ]
        let currentDate = Date()

        let onlineRecipeRecord = OnlineRecipeRecord(
            id: "TestId",
            name: "Banana Cupcake",
            creator: "TestUserId",
            servings: 2,
            cuisine: "Chinese",
            difficulty: .medium,
            ingredients: ingredientRecord,
            steps: steps,
            stepEdges: stepEdgeRecords,
            ratings: ratings,
            created: currentDate
        )

        let onlineRecipe = try OnlineRecipe(from: onlineRecipeRecord)

        XCTAssertEqual(onlineRecipe.id, "TestId")
        XCTAssertEqual(onlineRecipe.userId, "TestUserId")
        XCTAssertEqual(onlineRecipe.name, "Banana Cupcake")
        XCTAssertEqual(onlineRecipe.servings, 2)
        XCTAssertEqual(onlineRecipe.difficulty, .medium)
        XCTAssertEqual(onlineRecipe.cuisine, "Chinese")
        XCTAssertEqual(onlineRecipe.steps, steps)
        XCTAssertEqual(onlineRecipe.stepGraph, stepGraph)
        XCTAssertEqual(onlineRecipe.ingredients, ingredients)
        XCTAssertEqual(onlineRecipe.ratings, ratings)
        XCTAssertEqual(onlineRecipe.created, currentDate)

    }
}
