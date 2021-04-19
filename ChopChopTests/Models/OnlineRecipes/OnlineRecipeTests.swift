// swiftlint:disable line_length function_body_length type_body_length

import XCTest
@testable import ChopChop

class OnlineRecipeTests: XCTestCase {
    func testConstruct() throws {
        let onlineRecipe = try OnlineRecipe(id: "1", userId: "1", name: "Pancakes", servings: 2, difficulty: Difficulty.easy, cuisine: nil, stepGraph: RecipeStepGraph(), ingredients: [], ratings: [], created: Date())

        XCTAssertEqual(onlineRecipe.id, "1")
        XCTAssertEqual(onlineRecipe.userId, "1")
        XCTAssertEqual(onlineRecipe.name, "Pancakes")
        XCTAssertEqual(onlineRecipe.servings, 2)
        XCTAssertEqual(onlineRecipe.difficulty, Difficulty.easy)
        XCTAssertNil(onlineRecipe.cuisine)
        XCTAssertEqual(onlineRecipe.stepGraph, RecipeStepGraph())
        XCTAssertTrue(onlineRecipe.ingredients.isEmpty)
        XCTAssertTrue(onlineRecipe.ratings.isEmpty)
    }

    func testConstruct_fail() throws {
        XCTAssertThrowsError(try OnlineRecipe(id: "1", userId: "1", name: "        ", servings: 2, difficulty: nil, cuisine: nil, stepGraph: RecipeStepGraph(), ingredients: [], ratings: [], created: Date()))

        XCTAssertThrowsError(try OnlineRecipe(id: "1", userId: "1", name: "Pancakes", servings: 0, difficulty: nil, cuisine: nil, stepGraph: RecipeStepGraph(), ingredients: [], ratings: [], created: Date()))
    }

    func testConstruct_allFieldsFilled_success() throws {
        let steps = ["First step", "Second step", "Third Step"]
        let stepNodes = try steps.map({ RecipeStepNode(try RecipeStep($0)) })
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
        XCTAssertEqual(onlineRecipe.stepGraph, stepGraph)
        XCTAssertEqual(onlineRecipe.ingredients, ingredients)
        XCTAssertEqual(onlineRecipe.ratings, ratings)
        XCTAssertEqual(onlineRecipe.created, currentDate)
    }

    func testConstruct_optionalFieldsNotFilled_success() throws {
        let steps = ["First step", "Second step", "Third Step"]
        let stepNodes = try steps.map({ RecipeStepNode(try RecipeStep($0)) })
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
        XCTAssertEqual(onlineRecipe.stepGraph, stepGraph)
        XCTAssertEqual(onlineRecipe.ingredients, ingredients)
        XCTAssertEqual(onlineRecipe.ratings, ratings)
        XCTAssertEqual(onlineRecipe.created, currentDate)
    }

    func testConstruct_emptyName_fail() throws {
        let steps = ["First step", "Second step", "Third Step"]
        let stepNodes = try steps.map({ RecipeStepNode(try RecipeStep($0)) })
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
            stepGraph: stepGraph,
            ingredients: ingredients,
            ratings: ratings,
            created: currentDate
        ))
    }

    func testConstruct_servingBelowZero_fail() throws {
        let steps = ["First step", "Second step", "Third Step"]
        let stepNodes = try steps.map({ RecipeStepNode(try RecipeStep($0)) })
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
            stepGraph: stepGraph,
            ingredients: ingredients,
            ratings: ratings,
            created: currentDate
        ))
    }

    func testConvenienceInitializer_success() throws {
        let stepStrings = ["First step", "Second step", "Third Step"]
        let stepNodes = try stepStrings.map({ RecipeStepNode(try RecipeStep($0)) })
        let steps = [
            OnlineStepRecord(
                id: stepNodes[0].id.uuidString,
                content: stepStrings[0]),
            OnlineStepRecord(
                id: stepNodes[1].id.uuidString,
                content: stepStrings[1]),
            OnlineStepRecord(
                id: stepNodes[2].id.uuidString,
                content: stepStrings[2])
        ]
        let stepEdges = [
            Edge<RecipeStepNode>(source: stepNodes[0], destination: stepNodes[1]),
            Edge<RecipeStepNode>(source: stepNodes[1], destination: stepNodes[2])
        ].compactMap({ $0 })

        let stepGraph = try RecipeStepGraph(nodes: stepNodes, edges: stepEdges)
        let stepEdgeRecords = [
            OnlineStepEdgeRecord(sourceStepId: stepNodes[0].id.uuidString, destinationStepId: stepNodes[1].id.uuidString),
            OnlineStepEdgeRecord(sourceStepId: stepNodes[1].id.uuidString, destinationStepId: stepNodes[2].id.uuidString)
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
        XCTAssertEqual(onlineRecipe.stepGraph, stepGraph)
        XCTAssertEqual(onlineRecipe.ingredients, ingredients)
        XCTAssertEqual(onlineRecipe.ratings, ratings)
        XCTAssertEqual(onlineRecipe.created, currentDate)

    }

    func testConvenienceInitializer() throws {
        let node1 = RecipeStepNode(try RecipeStep("Cook the pancakes"))
        let node2 = RecipeStepNode(try RecipeStep("Make the pancakes"))

        let onlineRecipe = try OnlineRecipe(
            from: OnlineRecipeRecord(
                id: "1",
                name: "Pancakes",
                creator: "1",
                servings: 2,
                ingredients: [
                    OnlineIngredientRecord(
                        name: "Butter",
                        quantity: .count(2))],
                steps: [
                    OnlineStepRecord(
                        id: node1.id.uuidString,
                        content: "Cook the pancakes"),
                    OnlineStepRecord(
                        id: node2.id.uuidString,
                        content: "Make the pancakes")],
                stepEdges: [
                    OnlineStepEdgeRecord(
                        sourceStepId: node1.id.uuidString,
                        destinationStepId: node2.id.uuidString)],
                created: Date()))

        XCTAssertEqual(onlineRecipe.name, "Pancakes")
        XCTAssertEqual(onlineRecipe.servings, 2)
        XCTAssertEqual(onlineRecipe.ingredients, [try RecipeIngredient(name: "Butter", quantity: Quantity(.count, value: 2))])

        let edges = [Edge(source: node1, destination: node2)].compactMap { $0 }
        XCTAssertEqual(onlineRecipe.stepGraph, try RecipeStepGraph(nodes: [node1, node2], edges: edges))
    }

}
