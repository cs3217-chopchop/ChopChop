// swiftlint:disable type_body_length function_body_length file_length line_length
import XCTest
import GRDB
@testable import ChopChop

class AppDatabaseTests: XCTestCase {
    var dbWriter: DatabaseWriter!
    var appDatabase: AppDatabase!

    override func setUpWithError() throws {
        try super.setUpWithError()

        dbWriter = DatabaseQueue()
        appDatabase = try AppDatabase(dbWriter)
    }

    // MARK: - Database Schema Tests

    func testDatabaseSchema_recipeCategorySchema() throws {
        try dbWriter.read { db in
            try XCTAssertTrue(db.tableExists("recipeCategory"))
            let columns = try db.columns(in: "recipeCategory")
            let columnNames = Set(columns.map { $0.name })

            XCTAssertEqual(columnNames, ["id", "name"])
        }
    }

    func testDatabaseSchema_recipeSchema() throws {
        try dbWriter.read { db in
            try XCTAssertTrue(db.tableExists("recipe"))
            let columns = try db.columns(in: "recipe")
            let columnNames = Set(columns.map { $0.name })

            XCTAssertEqual(columnNames, ["id", "recipeCategoryId", "name", "servings", "difficulty", "onlineId"])
        }
    }

    func testDatabaseSchema_recipeIngredientSchema() throws {
        try dbWriter.read { db in
            try XCTAssertTrue(db.tableExists("recipeIngredient"))
            let columns = try db.columns(in: "recipeIngredient")
            let columnNames = Set(columns.map { $0.name })

            XCTAssertEqual(columnNames, ["id", "recipeId", "name", "quantity"])
        }
    }

    func testDatabaseSchema_recipeStepGraphSchema() throws {
        try dbWriter.read { db in
            try XCTAssertTrue(db.tableExists("recipeStepGraph"))
            let columns = try db.columns(in: "recipeStepGraph")
            let columnNames = Set(columns.map { $0.name })

            XCTAssertEqual(columnNames, ["id", "recipeId"])
        }
    }

    func testDatabaseSchema_recipeStepSchema() throws {
        try dbWriter.read { db in
            try XCTAssertTrue(db.tableExists("recipeStep"))
            let columns = try db.columns(in: "recipeStep")
            let columnNames = Set(columns.map { $0.name })

            XCTAssertEqual(columnNames, ["id", "graphId", "content"])
        }
    }

    func testDatabaseSchema_recipeStepEdgeSchema() throws {
        try dbWriter.read { db in
            try XCTAssertTrue(db.tableExists("recipeStepEdge"))
            let columns = try db.columns(in: "recipeStepEdge")
            let columnNames = Set(columns.map { $0.name })

            XCTAssertEqual(columnNames, ["id", "graphId", "sourceId", "destinationId"])
        }
    }

    func testDatabaseSchema_ingredientCategorySchema() throws {
        try dbWriter.read { db in
            try XCTAssertTrue(db.tableExists("ingredientCategory"))
            let columns = try db.columns(in: "ingredientCategory")
            let columnNames = Set(columns.map { $0.name })

            XCTAssertEqual(columnNames, ["id", "name"])
        }
    }

    func testDatabaseSchema_ingredientSchema() throws {
        try dbWriter.read { db in
            try XCTAssertTrue(db.tableExists("ingredient"))
            let columns = try db.columns(in: "ingredient")
            let columnNames = Set(columns.map { $0.name })

            XCTAssertEqual(columnNames, ["id", "ingredientCategoryId", "name", "quantityType"])
        }
    }

    func testDatabaseSchema_ingredientBatchSchema() throws {
        try dbWriter.read { db in
            try XCTAssertTrue(db.tableExists("ingredientBatch"))
            let columns = try db.columns(in: "ingredientBatch")
            let columnNames = Set(columns.map { $0.name })

            XCTAssertEqual(columnNames, ["id", "ingredientId", "expiryDate", "quantity"])
        }
    }

    // MARK: - Recipe CRUD Tests

    func testSaveRecipe_insertsInvalidName_throwsError() throws {
        var recipe = RecipeRecord(name: "", servings: 2)

        try XCTAssertThrowsError(appDatabase.saveRecipe(&recipe))
    }

    func testSaveRecipe_insertsDuplicateName_throwsError() throws {
        var recipe1 = RecipeRecord(name: "Pancakes", servings: 2)
        var recipe2 = RecipeRecord(name: "Pancakes", servings: 2)

        try appDatabase.saveRecipe(&recipe1)
        try XCTAssertThrowsError(appDatabase.saveRecipe(&recipe2))
    }

    func testSaveRecipe_insertsValidIngredients_success() throws {
        var recipe = RecipeRecord(name: "Pancakes", servings: 2)
        var ingredients = [
            RecipeIngredientRecord(name: "Flour", quantity: .mass(120, unit: .gram)),
            RecipeIngredientRecord(name: "Baking Powder", quantity: .volume(7.5, unit: .milliliter)),
            RecipeIngredientRecord(name: "Salt", quantity: .volume(0.312_5, unit: .milliliter)),
            RecipeIngredientRecord(name: "Milk", quantity: .volume(1, unit: .cup)),
            RecipeIngredientRecord(name: "Egg", quantity: .count(1)),
            RecipeIngredientRecord(name: "Sugar", quantity: .volume(1, unit: .tablespoon))
        ]
        var graph = RecipeStepGraph()

        try appDatabase.saveRecipe(&recipe, ingredients: &ingredients, stepGraph: &graph)

        try dbWriter.read { db in
            try XCTAssertTrue(recipe.exists(db))

            for ingredient in ingredients {
                try XCTAssertTrue(ingredient.exists(db))
            }
        }
    }

    func testSaveRecipe_insertsDuplicateIngredientsDifferentRecipes_success() throws {
        var pancakeRecipe = RecipeRecord(name: "Pancakes", servings: 2)
        var pancakeIngredients = [
            RecipeIngredientRecord(name: "Flour", quantity: .mass(120, unit: .gram)),
            RecipeIngredientRecord(name: "Baking Powder", quantity: .volume(7.5, unit: .milliliter)),
            RecipeIngredientRecord(name: "Salt", quantity: .volume(0.312_5, unit: .milliliter)),
            RecipeIngredientRecord(name: "Milk", quantity: .volume(1, unit: .cup)),
            RecipeIngredientRecord(name: "Egg", quantity: .count(1)),
            RecipeIngredientRecord(name: "Sugar", quantity: .volume(1, unit: .tablespoon))
        ]
        var scrambledEggRecipe = RecipeRecord(name: "Scrambled Eggs", servings: 2)
        var scrambledEggIngredients = [
            RecipeIngredientRecord(name: "Egg", quantity: .count(3)),
            RecipeIngredientRecord(name: "Milk", quantity: .volume(0.03, unit: .liter)),
            RecipeIngredientRecord(name: "Butter", quantity: .volume(10, unit: .milliliter)),
            RecipeIngredientRecord(name: "Salt", quantity: .volume(1.25, unit: .milliliter)),
            RecipeIngredientRecord(name: "Pepper", quantity: .volume(2.5, unit: .milliliter))
        ]
        var graph = RecipeStepGraph()

        try appDatabase.saveRecipe(&pancakeRecipe, ingredients: &pancakeIngredients, stepGraph: &graph)
        try appDatabase.saveRecipe(&scrambledEggRecipe, ingredients: &scrambledEggIngredients, stepGraph: &graph)

        try dbWriter.read { db in
            try XCTAssertTrue(pancakeRecipe.exists(db))
            try XCTAssertTrue(scrambledEggRecipe.exists(db))

            for ingredient in pancakeIngredients {
                try XCTAssertTrue(ingredient.exists(db))
            }

            for ingredient in scrambledEggIngredients {
                try XCTAssertTrue(ingredient.exists(db))
            }
        }
    }

    func testSaveRecipe_insertsInvalidIngredients_throwsError() throws {
        var recipe = RecipeRecord(name: "Pancakes", servings: 2)
        var ingredients = [
            RecipeIngredientRecord(name: "Flour", quantity: .mass(120, unit: .gram)),
            RecipeIngredientRecord(name: "Baking Powder", quantity: .volume(7.5, unit: .milliliter)),
            RecipeIngredientRecord(name: "Salt", quantity: .volume(0.312_5, unit: .milliliter)),
            RecipeIngredientRecord(name: "Milk", quantity: .volume(1, unit: .cup)),
            RecipeIngredientRecord(name: "Egg", quantity: .count(1)),
            RecipeIngredientRecord(name: "Sugar", quantity: .volume(1, unit: .tablespoon)),
            RecipeIngredientRecord(name: "", quantity: .count(0))
        ]
        var graph = RecipeStepGraph()

        try XCTAssertThrowsError(appDatabase.saveRecipe(&recipe, ingredients: &ingredients, stepGraph: &graph))
    }

    func testSaveRecipe_insertsDuplicateIngredients_throwsError() throws {
        var recipe = RecipeRecord(name: "Pancakes", servings: 2)
        var ingredients = [
            RecipeIngredientRecord(name: "Flour", quantity: .mass(120, unit: .gram)),
            RecipeIngredientRecord(name: "Baking Powder", quantity: .volume(7.5, unit: .milliliter)),
            RecipeIngredientRecord(name: "Salt", quantity: .volume(0.312_5, unit: .milliliter)),
            RecipeIngredientRecord(name: "Milk", quantity: .volume(1, unit: .cup)),
            RecipeIngredientRecord(name: "Egg", quantity: .count(1)),
            RecipeIngredientRecord(name: "Sugar", quantity: .volume(1, unit: .tablespoon)),
            RecipeIngredientRecord(name: "Sugar", quantity: .volume(1, unit: .tablespoon))
        ]
        var graph = RecipeStepGraph()

        try XCTAssertThrowsError(appDatabase.saveRecipe(&recipe, ingredients: &ingredients, stepGraph: &graph))
    }

    func testSaveRecipe_insertsValidGraph_success() throws {
        var recipe = RecipeRecord(name: "Pancakes", servings: 2)
        var ingredients: [RecipeIngredientRecord] = []
        var graph = RecipeStepGraph()

        try appDatabase.saveRecipe(&recipe, ingredients: &ingredients, stepGraph: &graph)

        try dbWriter.read { db in
            guard let graphRecord = try recipe.stepGraph.fetchOne(db) else {
                XCTFail("Graph not found")
                return
            }

            try XCTAssertTrue(graphRecord.exists(db))
        }
    }

    func testSaveRecipe_insertsValidSteps_success() throws {
        var recipe = RecipeRecord(name: "Pancakes", servings: 2)
        var ingredients: [RecipeIngredientRecord] = []
        let steps = [
            try RecipeStep("""
                In a large bowl, mix dry ingredients together until well-blended.
                """),
            try RecipeStep("""
                Add milk and mix well until smooth.
                """),
            try RecipeStep("""
                Separate the egg, placing the whites in a medium bowl and the yolks in the batter. Mix well.
                """),
            try RecipeStep("""
                Beat whites until stiff and then fold into batter gently.
                """),
            try RecipeStep("""
                Pour ladles of the mixture into a non-stick pan, one at a time.
                """),
            try RecipeStep("""
                Cook until the edges are dry and bubbles appear on surface. Flip; cook until golden. Yields 12 to 14 \
                pancakes.
                """)
        ]
        let nodes = steps.map { RecipeStepNode($0) }
        var graph = try RecipeStepGraph(nodes: nodes, edges: [])

        try appDatabase.saveRecipe(&recipe, ingredients: &ingredients, stepGraph: &graph)

        try dbWriter.read { db in
            try XCTAssertTrue(recipe.exists(db))

            let graphRecord = try recipe.stepGraph.fetchOne(db)

            guard let stepRecords = try graphRecord?.steps.fetchAll(db) else {
                XCTFail("Graph steps cannot be found")
                return
            }

            for step in try stepRecords {
                XCTAssertTrue(steps.contains(where: { $0.content == step.content }))
            }
        }
    }

    func testSaveRecipe_insertsValidEdges_success() throws {
        var recipe = RecipeRecord(name: "Pancakes", servings: 2)
        var ingredients: [RecipeIngredientRecord] = []
        let steps = [
            try RecipeStep("""
                In a large bowl, mix dry ingredients together until well-blended.
                """),
            try RecipeStep("""
                Add milk and mix well until smooth.
                """),
            try RecipeStep("""
                Separate the egg, placing the whites in a medium bowl and the yolks in the batter. Mix well.
                """),
            try RecipeStep("""
                Beat whites until stiff and then fold into batter gently.
                """),
            try RecipeStep("""
                Pour ladles of the mixture into a non-stick pan, one at a time.
                """),
            try RecipeStep("""
                Cook until the edges are dry and bubbles appear on surface. Flip; cook until golden. Yields 12 to 14 \
                pancakes.
                """)
        ]
        let nodes = steps.map { RecipeStepNode($0) }
        let edges = [Edge<RecipeStepNode>(source: nodes[0], destination: nodes[1]),
                     Edge<RecipeStepNode>(source: nodes[1], destination: nodes[2]),
                     Edge<RecipeStepNode>(source: nodes[2], destination: nodes[3]),
                     Edge<RecipeStepNode>(source: nodes[0], destination: nodes[3])].compactMap { $0 }
        var graph = try RecipeStepGraph(nodes: nodes, edges: edges)

        try appDatabase.saveRecipe(&recipe, ingredients: &ingredients, stepGraph: &graph)

        try dbWriter.read { db in
            try XCTAssertTrue(recipe.exists(db))
            let graphRecord = try recipe.stepGraph.fetchOne(db)

            guard let edgeRecords = try graphRecord?.edges.fetchAll(db) else {
                XCTFail("Graph edges cannot be found")
                return
            }

            for edge in edgeRecords {
                let source = try edge.source.fetchOne(db)
                let destination = try edge.destination.fetchOne(db)

                XCTAssertTrue(
                    edges.contains(
                        where: {
                            $0.source.label.content == source?.content
                                && $0.destination.label.content == destination?.content
                        }))
            }
        }
    }

    func testSaveRecipe_insertsDuplicateOnlineId_throwsError() throws {
        var recipe1 = RecipeRecord(onlineId: "1", name: "Pancakes", servings: 2)
        var recipe2 = RecipeRecord(onlineId: "1", name: "Fluffy Pancakes", servings: 1)

        try appDatabase.saveRecipe(&recipe1)
        try XCTAssertThrowsError(appDatabase.saveRecipe(&recipe2))
    }

    func testDeleteRecipes() throws {
        var recipe1 = RecipeRecord(name: "Pancakes", servings: 2)
        var recipe2 = RecipeRecord(name: "Scrambled Eggs", servings: 2)
        var ingredients = [
            RecipeIngredientRecord(name: "Flour", quantity: .mass(120, unit: .gram)),
            RecipeIngredientRecord(name: "Baking Powder", quantity: .volume(7.5, unit: .milliliter)),
            RecipeIngredientRecord(name: "Salt", quantity: .volume(0.312_5, unit: .milliliter)),
            RecipeIngredientRecord(name: "Milk", quantity: .volume(1, unit: .cup)),
            RecipeIngredientRecord(name: "Egg", quantity: .count(1)),
            RecipeIngredientRecord(name: "Sugar", quantity: .volume(1, unit: .tablespoon))
        ]
        var steps = [
            RecipeStepRecord(content: """
                In a large bowl, mix dry ingredients together until well-blended.
                """),
            RecipeStepRecord(content: """
                Add milk and mix well until smooth.
                """),
            RecipeStepRecord(content: """
                Separate the egg, placing the whites in a medium bowl and the yolks in the batter. Mix well.
                """),
            RecipeStepRecord(content: """
                Beat whites until stiff and then fold into batter gently.
                """),
            RecipeStepRecord(content: """
                Pour ladles of the mixture into a non-stick pan, one at a time.
                """),
            RecipeStepRecord(content: """
                Cook until the edges are dry and bubbles appear on surface. Flip; cook until golden. Yields 12 to 14 \
                pancakes.
                """)
        ]
        var graph = RecipeStepGraphRecord()
        var edges: [RecipeStepEdgeRecord] = []

        try dbWriter.write { db in
            try recipe1.insert(db)
            try recipe2.insert(db)

            for index in 0..<ingredients.count {
                ingredients[index].recipeId = recipe1.id
                try ingredients[index].insert(db)
            }

            graph.recipeId = recipe1.id
            try graph.insert(db)

            for index in 0..<steps.count {
                steps[index].graphId = graph.id
                try steps[index].insert(db)
            }

            edges.append(
                contentsOf: [RecipeStepEdgeRecord(sourceId: steps[0].id, destinationId: steps[1].id),
                             RecipeStepEdgeRecord(sourceId: steps[1].id, destinationId: steps[2].id),
                             RecipeStepEdgeRecord(sourceId: steps[2].id, destinationId: steps[3].id),
                             RecipeStepEdgeRecord(sourceId: steps[0].id, destinationId: steps[3].id)])

            for index in 0..<edges.count {
                edges[index].graphId = graph.id
                try edges[index].insert(db)
            }
        }

        guard let recipeId = recipe1.id, graph.id != nil else {
            XCTFail("Recipes should have a non-nil ID after insertion into database")
            return
        }

        try appDatabase.deleteRecipes(ids: [recipeId])

        try dbWriter.read { db in
            try XCTAssertFalse(recipe1.exists(db))

            // Deleting recipes should also delete their associated ingredients and graph,
            // which should also delete its associated steps and edges
            for ingredient in ingredients {
                try XCTAssertFalse(ingredient.exists(db))
            }

            try XCTAssertFalse(graph.exists(db))

            for step in steps {
                try XCTAssertFalse(step.exists(db))
            }

            for edge in edges {
                try XCTAssertFalse(edge.exists(db))
            }
        }

        try XCTAssertEqual(dbWriter.read(RecipeRecord.fetchCount), 1)
    }

    func testDeleteAllRecipes() throws {
        var recipe1 = RecipeRecord(name: "Pancakes", servings: 2)
        var recipe2 = RecipeRecord(name: "Scrambled Eggs", servings: 2)

        try dbWriter.write { db in
            try recipe1.insert(db)
            try recipe2.insert(db)
        }

        try appDatabase.deleteAllRecipes()

        try XCTAssertEqual(dbWriter.read(RecipeRecord.fetchCount), 0)
    }

    // MARK: - Recipe Category Tests

    func testSaveRecipeCategory_insertsInvalidName_throwsError() throws {
        var category = RecipeCategoryRecord(name: "")

        try XCTAssertThrowsError(appDatabase.saveRecipeCategory(&category))
    }

    func testSaveRecipeCategory_insertsDuplicateName_throwsError() throws {
        var category1 = RecipeCategoryRecord(name: "Japanese")
        var category2 = RecipeCategoryRecord(name: "Japanese")

        try appDatabase.saveRecipeCategory(&category1)
        try XCTAssertThrowsError(appDatabase.saveRecipeCategory(&category2))
    }

    func testDeleteRecipeCategory_recipesRemaining_success() throws {
        var category = RecipeCategoryRecord(name: "American")
        var recipe = RecipeRecord(name: "Pancakes", servings: 2)

        try dbWriter.write { db in
            try category.insert(db)

            recipe.recipeCategoryId = category.id

            try recipe.insert(db)
        }

        guard let id = category.id else {
            XCTFail("Recipe categories should have a non-nil ID after insertion into database")
            return
        }

        try appDatabase.deleteRecipeCategories(ids: [id])

        try dbWriter.read { db in
            try XCTAssertFalse(category.exists(db))

            // Deleting categories should set the category ID of its contained recipes to nil
            if let fetchedRecipe = try RecipeRecord.fetchOne(db, key: recipe.id) {
                XCTAssertNil(fetchedRecipe.recipeCategoryId)
            } else {
                XCTFail("Inserted recipe cannot be found")
            }
        }
    }

    func testSaveRecipe_insertsDefaultCategoryNil_success() throws {
        var recipe = RecipeRecord(name: "Pancakes", servings: 2)

        try appDatabase.saveRecipe(&recipe)

        XCTAssertNil(recipe.recipeCategoryId)
    }

    func testSaveRecipe_insertsExistingCategory_success() throws {
        var category = RecipeCategoryRecord(name: "American")

        try dbWriter.write { db in
            try category.insert(db)
        }

        var recipe = RecipeRecord(recipeCategoryId: category.id, name: "Pancakes", servings: 2)

        try appDatabase.saveRecipe(&recipe)

        XCTAssertEqual(recipe.recipeCategoryId, recipe.id)
    }

    func testSaveRecipe_insertsMissingCategory_success() throws {
        var recipe = RecipeRecord(recipeCategoryId: 1, name: "Pancakes", servings: 2)

        try XCTAssertThrowsError(appDatabase.saveRecipe(&recipe))
    }

    // MARK: - Ingredient CRUD Tests

    func testSaveIngredient_insertsInvalidName_throwsError() throws {
        var ingredient = IngredientRecord(name: "", quantityType: .count)

        try XCTAssertThrowsError(appDatabase.saveIngredient(&ingredient))
    }

    func testSaveIngredient_insertsDuplicateName_throwsError() throws {
        var ingredient1 = IngredientRecord(name: "Egg", quantityType: .count)
        var ingredient2 = IngredientRecord(name: "Egg", quantityType: .count)

        try appDatabase.saveIngredient(&ingredient1)
        try XCTAssertThrowsError(appDatabase.saveIngredient(&ingredient2))
    }

    func testSaveIngredient_insertsValidBatches_success() throws {
        var ingredient = IngredientRecord(name: "Egg", quantityType: .count)
        var batches = [
            IngredientBatchRecord(expiryDate: .today,
                                  quantity: .count(12)),
            IngredientBatchRecord(expiryDate: Date(timeIntervalSinceNow: 60 * 60 * 24).startOfDay,
                                  quantity: .count(13)),
            IngredientBatchRecord(quantity: .count(14))
        ]

        try appDatabase.saveIngredient(&ingredient, batches: &batches)

        try dbWriter.read { db in
            try XCTAssertTrue(ingredient.exists(db))

            for batch in batches {
                try XCTAssertTrue(batch.exists(db))
            }
        }
    }

    func testSaveIngredient_insertsInvalidBatches_throwsError() throws {
        var ingredient = IngredientRecord(name: "Egg", quantityType: .count)
        var batches = [
            IngredientBatchRecord(expiryDate: .today,
                                  quantity: .count(12)),
            IngredientBatchRecord(expiryDate: .today,
                                  quantity: .count(13))
        ]

        try XCTAssertThrowsError(appDatabase.saveIngredient(&ingredient, batches: &batches))
    }

    func testSaveIngredient_insertsBatchesWithWrongType_throwsError() throws {
        var ingredient = IngredientRecord(name: "Egg", quantityType: .mass)
        var batches = [
            IngredientBatchRecord(expiryDate: .today,
                                  quantity: .count(12)),
            IngredientBatchRecord(expiryDate: Date(timeIntervalSinceNow: 60 * 60 * 24).startOfDay,
                                  quantity: .count(13)),
            IngredientBatchRecord(quantity: .count(14))
        ]

        try XCTAssertThrowsError(appDatabase.saveIngredient(&ingredient, batches: &batches))
    }

    func testDeleteIngredients() throws {
        var ingredient1 = IngredientRecord(name: "Egg", quantityType: .count)
        var ingredient2 = IngredientRecord(name: "Salt", quantityType: .mass)
        var ingredient3 = IngredientRecord(name: "Sugar", quantityType: .mass)
        var batches = [
            IngredientBatchRecord(expiryDate: .today,
                                  quantity: .count(12)),
            IngredientBatchRecord(expiryDate: Date(timeIntervalSinceNow: 60 * 60 * 24).startOfDay,
                                  quantity: .count(13)),
            IngredientBatchRecord(quantity: .count(14))
        ]

        try dbWriter.write { db in
            try ingredient1.insert(db)
            try ingredient2.insert(db)
            try ingredient3.insert(db)

            for index in 0..<batches.count {
                batches[index].ingredientId = ingredient1.id
                try batches[index].insert(db)
            }
        }

        guard let id = ingredient1.id else {
            XCTFail("Ingredients should have a non-nil ID after insertion into database")
            return
        }

        try appDatabase.deleteIngredients(ids: [id])

        try dbWriter.read { db in
            try XCTAssertFalse(ingredient1.exists(db))

            // Deleting ingredients should also delete their associated batches
            for batch in batches {
                try XCTAssertFalse(batch.exists(db))
            }
        }

        try XCTAssertEqual(dbWriter.read(IngredientRecord.fetchCount), 2)
    }

    func testDeleteAllIngredients() throws {
        var ingredient1 = IngredientRecord(name: "Egg", quantityType: .count)
        var ingredient2 = IngredientRecord(name: "Salt", quantityType: .mass)

        try dbWriter.write { db in
            try ingredient1.insert(db)
            try ingredient2.insert(db)
        }

        try appDatabase.deleteAllIngredients()

        try XCTAssertEqual(dbWriter.read(IngredientRecord.fetchCount), 0)
    }

    // MARK: - Ingredient Category Tests

    func testSaveIngredientCategory_insertsInvalidName_throwsError() throws {
        var category = IngredientCategoryRecord(name: "")

        try XCTAssertThrowsError(appDatabase.saveIngredientCategory(&category))
    }

    func testSaveIngredientCategory_insertsDuplicateName_throwsError() throws {
        var category1 = IngredientCategoryRecord(name: "Spices")
        var category2 = IngredientCategoryRecord(name: "Spices")

        try appDatabase.saveIngredientCategory(&category1)
        try XCTAssertThrowsError(appDatabase.saveIngredientCategory(&category2))
    }

    func testDeleteIngredientCategory_ingredientsRemaining_success() throws {
        var category = IngredientCategoryRecord(name: "Spices")
        var ingredient = IngredientRecord(name: "Pepper", quantityType: .mass)

        try dbWriter.write { db in
            try category.insert(db)

            ingredient.ingredientCategoryId = category.id

            try ingredient.insert(db)
        }

        guard let id = category.id else {
            XCTFail("Recipe categories should have a non-nil ID after insertion into database")
            return
        }

        try appDatabase.deleteIngredientCategories(ids: [id])

        try dbWriter.read { db in
            try XCTAssertFalse(category.exists(db))

            // Deleting categories should set the category ID of its contained ingredients to nil
            if let fetchedIngredient = try IngredientRecord.fetchOne(db, key: ingredient.id) {
                XCTAssertNil(fetchedIngredient.ingredientCategoryId)
            } else {
                XCTFail("Inserted ingredient cannot be found")
            }
        }
    }

    func testSaveIngredient_insertsDefaultCategoryNil_success() throws {
        var ingredient = IngredientRecord(name: "Pepper", quantityType: .mass)

        try appDatabase.saveIngredient(&ingredient)

        XCTAssertNil(ingredient.ingredientCategoryId)
    }

    func testSaveIngredient_insertsExistingCategory_success() throws {
        var category = IngredientCategoryRecord(name: "Spices")

        try dbWriter.write { db in
            try category.insert(db)
        }

        var ingredient = IngredientRecord(ingredientCategoryId: category.id, name: "Pepper", quantityType: .mass)

        try appDatabase.saveIngredient(&ingredient)

        XCTAssertEqual(ingredient.ingredientCategoryId, category.id)
    }

    func testSaveIngredient_insertsMissingCategory_success() throws {
        var ingredient = IngredientRecord(ingredientCategoryId: 1, name: "Pepper", quantityType: .mass)

        try XCTAssertThrowsError(appDatabase.saveIngredient(&ingredient))
    }

    // MARK: - Recipes Publisher Tests

    func testRecipesPublisher_publishesRightOnSubscription() throws {
        var recipes: [RecipeRecord]?
        _ = appDatabase.recipesPublisher().sink { completion in
            if case let .failure(error) = completion {
                XCTFail("Unexpected error \(error)")
            }
        } receiveValue: {
            recipes = $0
        }

        XCTAssertNotNil(recipes)
    }

    func testRecipesPublisher_orderedByName_publishesOrderedRecipes() throws {
        var recipe1 = RecipeRecord(name: "Scrambled Eggs", servings: 2)
        var recipe2 = RecipeRecord(name: "Pancakes", servings: 2)

        try dbWriter.write { db in
            try recipe1.insert(db)
            try recipe2.insert(db)
        }

        let exp = expectation(description: "Recipes")
        var recipes: [RecipeRecord]?
        let cancellable = appDatabase.recipesPublisher().sink { completion in
            if case let .failure(error) = completion {
                XCTFail("Unexpected error \(error)")
            }
        } receiveValue: {
            recipes = $0
            exp.fulfill()
        }

        withExtendedLifetime(cancellable) {
            waitForExpectations(timeout: 1, handler: nil)
        }

        XCTAssertEqual(recipes, [recipe2, recipe1])
    }

    func testRecipesPublisher_filteredByCategoryOrderedByName_publishesFilteredOrderedRecipes() throws {
        var category1 = RecipeCategoryRecord(name: "American")
        var category2 = RecipeCategoryRecord(name: "Japanese")

        var recipe1 = RecipeRecord(name: "Scrambled Eggs", servings: 2)
        var recipe2 = RecipeRecord(name: "Pancakes", servings: 2)
        var recipe3 = RecipeRecord(name: "Miso Soup", servings: 2)
        var recipe4 = RecipeRecord(name: "Oyakodon", servings: 2)

        try dbWriter.write { db in
            try category1.insert(db)
            try category2.insert(db)

            recipe1.recipeCategoryId = category1.id
            recipe2.recipeCategoryId = category1.id
            recipe3.recipeCategoryId = category2.id
            recipe4.recipeCategoryId = category2.id

            try recipe1.insert(db)
            try recipe2.insert(db)
            try recipe3.insert(db)
            try recipe4.insert(db)
        }

        guard let id = category1.id else {
            XCTFail("Recipe categories should have a non-nil ID after insertion into database")
            return
        }

        let exp = expectation(description: "Recipes")
        var recipes: [RecipeRecord]?
        let cancellable = appDatabase.recipesPublisher(categoryIds: [id]).sink { completion in
            if case let .failure(error) = completion {
                XCTFail("Unexpected error \(error)")
            }
        } receiveValue: {
            recipes = $0
            exp.fulfill()
        }

        withExtendedLifetime(cancellable) {
            waitForExpectations(timeout: 1, handler: nil)
        }

        XCTAssertEqual(recipes, [recipe2, recipe1])
    }

    func testRecipesPublisher_filteredByName_publishesFilteredRecipes() throws {
        var recipe1 = RecipeRecord(name: "Scrambled Eggs", servings: 1)
        var recipe2 = RecipeRecord(name: "Pancakes", servings: 1)
        var recipe3 = RecipeRecord(name: "Eggs Benedict", servings: 1)

        try dbWriter.write { db in
            try recipe1.insert(db)
            try recipe2.insert(db)
            try recipe3.insert(db)
        }

        let exp = expectation(description: "Recipes")
        var recipes: [RecipeRecord]?
        let cancellable = appDatabase.recipesPublisher(query: "egg").sink { completion in
            if case let .failure(error) = completion {
                XCTFail("Unexpected error \(error)")
            }
        } receiveValue: {
            recipes = $0
            exp.fulfill()
        }

        withExtendedLifetime(cancellable) {
            waitForExpectations(timeout: 1, handler: nil)
        }

        XCTAssertEqual(recipes, [recipe3, recipe1])
    }

    // MARK: - Ingredients Publisher Tests

    func testIngredientsPublisher_publishesRightOnSubscription() throws {
        var ingredients: [IngredientRecord]?
        _ = appDatabase.ingredientsPublisher().sink { completion in
            if case let .failure(error) = completion {
                XCTFail("Unexpected error \(error)")
            }
        } receiveValue: {
            ingredients = $0.map { IngredientRecord(id: $0.id,
                                                    ingredientCategoryId: $0.ingredientCategoryId,
                                                    name: $0.name,
                                                    quantityType: $0.quantityType)
            }
        }

        XCTAssertNotNil(ingredients)
    }

    func testIngredientsPublisher_orderedByName_publishesOrderedIngredients() throws {
        var ingredient1 = IngredientRecord(name: "Sugar", quantityType: .mass)
        var ingredient2 = IngredientRecord(name: "Salt", quantityType: .mass)

        try dbWriter.write { db in
            try ingredient1.insert(db)
            try ingredient2.insert(db)
        }

        let exp = expectation(description: "Ingredients")
        var ingredients: [IngredientRecord]?
        let cancellable = appDatabase.ingredientsPublisher().sink { completion in
            if case let .failure(error) = completion {
                XCTFail("Unexpected error \(error)")
            }
        } receiveValue: {
            ingredients = $0.map { IngredientRecord(id: $0.id,
                                                    ingredientCategoryId: $0.ingredientCategoryId,
                                                    name: $0.name,
                                                    quantityType: $0.quantityType)
            }
            exp.fulfill()
        }

        withExtendedLifetime(cancellable) {
            waitForExpectations(timeout: 1, handler: nil)
        }

        XCTAssertEqual(ingredients, [ingredient2, ingredient1])
    }

    func testIngredientsPublisher_filteredByCategoryOrderedByName_publishesFilteredOrderedIngredients() throws {
        var category1 = IngredientCategoryRecord(name: "Spices")
        var category2 = IngredientCategoryRecord(name: "Dairy")

        var ingredient1 = IngredientRecord(name: "Sugar", quantityType: .mass)
        var ingredient2 = IngredientRecord(name: "Salt", quantityType: .mass)
        var ingredient3 = IngredientRecord(name: "Milk", quantityType: .volume)
        var ingredient4 = IngredientRecord(name: "Egg", quantityType: .count)

        try dbWriter.write { db in
            try category1.insert(db)
            try category2.insert(db)

            ingredient1.ingredientCategoryId = category1.id
            ingredient2.ingredientCategoryId = category1.id
            ingredient3.ingredientCategoryId = category2.id
            ingredient4.ingredientCategoryId = category2.id

            try ingredient1.insert(db)
            try ingredient2.insert(db)
            try ingredient3.insert(db)
            try ingredient4.insert(db)
        }

        guard let id = category2.id else {
            XCTFail("Ingredient categories should have a non-nil ID after insertion into database")
            return
        }

        let exp = expectation(description: "Ingredients")
        var ingredients: [IngredientRecord]?
        let cancellable = appDatabase.ingredientsPublisher(categoryIds: [id])
            .sink { completion in
            if case let .failure(error) = completion {
                XCTFail("Unexpected error \(error)")
            }
        } receiveValue: {
            ingredients = $0.map { IngredientRecord(id: $0.id,
                                                    ingredientCategoryId: $0.ingredientCategoryId,
                                                    name: $0.name,
                                                    quantityType: $0.quantityType)
            }
            exp.fulfill()
            }

        withExtendedLifetime(cancellable) {
            waitForExpectations(timeout: 1, handler: nil)
        }

        XCTAssertEqual(ingredients, [ingredient4, ingredient3])
    }

    func testIngredientsPublisher_filteredByName_publishesFilteredIngredients() throws {
        var ingredient1 = IngredientRecord(name: "Baking Powder", quantityType: .mass)
        var ingredient2 = IngredientRecord(name: "Baking Soda", quantityType: .mass)
        var ingredient3 = IngredientRecord(name: "Salt", quantityType: .mass)

        try dbWriter.write { db in
            try ingredient1.insert(db)
            try ingredient2.insert(db)
            try ingredient3.insert(db)
        }

        let exp = expectation(description: "Ingredients")
        var ingredients: [IngredientRecord]?
        let cancellable = appDatabase.ingredientsPublisher(query: "baking").sink { completion in
            if case let .failure(error) = completion {
                XCTFail("Unexpected error \(error)")
            }
        } receiveValue: {
            ingredients = $0.map { IngredientRecord(id: $0.id,
                                                    ingredientCategoryId: $0.ingredientCategoryId,
                                                    name: $0.name,
                                                    quantityType: $0.quantityType)
            }
            exp.fulfill()
        }

        withExtendedLifetime(cancellable) {
            waitForExpectations(timeout: 1, handler: nil)
        }

        XCTAssertEqual(ingredients, [ingredient1, ingredient2])
    }

    // MARK: - Model Fetch Tests

    func testFetchRecipe() throws {
        var categoryRecord = RecipeCategoryRecord(name: "American")
        var recipeRecord = RecipeRecord(name: "Pancakes", servings: 1)
        var ingredientRecords = [
            RecipeIngredientRecord(name: "Flour", quantity: .mass(120, unit: .gram)),
            RecipeIngredientRecord(name: "Baking Powder", quantity: .volume(7.5, unit: .milliliter)),
            RecipeIngredientRecord(name: "Salt", quantity: .volume(0.312_5, unit: .milliliter)),
            RecipeIngredientRecord(name: "Milk", quantity: .volume(1, unit: .cup)),
            RecipeIngredientRecord(name: "Egg", quantity: .count(1)),
            RecipeIngredientRecord(name: "Sugar", quantity: .volume(1, unit: .tablespoon))
        ]
        var stepRecords = [
            RecipeStepRecord(content: """
                In a large bowl, mix dry ingredients together until well-blended.
                """),
            RecipeStepRecord(content: """
                Add milk and mix well until smooth.
                """),
            RecipeStepRecord(content: """
                Separate the egg, placing the whites in a medium bowl and the yolks in the batter. Mix well.
                """),
            RecipeStepRecord(content: """
                Beat whites until stiff and then fold into batter gently.
                """),
            RecipeStepRecord(content: """
                Pour ladles of the mixture into a non-stick pan, one at a time.
                """),
            RecipeStepRecord(content: """
                Cook until the edges are dry and bubbles appear on surface. Flip; cook until golden. Yields 12 to 14 \
                pancakes.
                """)
        ]
        var graphRecord = RecipeStepGraphRecord()
        var edgeRecords: [RecipeStepEdgeRecord] = []

        try dbWriter.write { db in
            try categoryRecord.insert(db)

            recipeRecord.recipeCategoryId = categoryRecord.id

            try recipeRecord.insert(db)

            for index in 0..<ingredientRecords.count {
                ingredientRecords[index].recipeId = recipeRecord.id
                try ingredientRecords[index].insert(db)
            }

            graphRecord.recipeId = recipeRecord.id
            try graphRecord.insert(db)

            for index in 0..<stepRecords.count {
                stepRecords[index].graphId = graphRecord.id
                try stepRecords[index].insert(db)
            }

            edgeRecords.append(
                contentsOf: [RecipeStepEdgeRecord(sourceId: stepRecords[0].id, destinationId: stepRecords[1].id),
                             RecipeStepEdgeRecord(sourceId: stepRecords[1].id, destinationId: stepRecords[2].id),
                             RecipeStepEdgeRecord(sourceId: stepRecords[2].id, destinationId: stepRecords[3].id),
                             RecipeStepEdgeRecord(sourceId: stepRecords[0].id, destinationId: stepRecords[3].id)])

            for index in 0..<edgeRecords.count {
                edgeRecords[index].graphId = graphRecord.id
                try edgeRecords[index].insert(db)
            }
        }

        let nodes = stepRecords.map { stepRecord -> RecipeStepNode? in
            guard let step = try? RecipeStep(stepRecord.content) else {
                return nil
            }

            return RecipeStepNode(step)
        }.compactMap({ $0 })
        let edges = edgeRecords.map { edgeRecord -> Edge<RecipeStepNode>? in
            guard let sourceRecord = stepRecords.first(where: { $0.id == edgeRecord.sourceId }),
                  let destinationRecord = stepRecords.first(where: { $0.id == edgeRecord.destinationId }),
                  let sourceStep = try? RecipeStep(sourceRecord.content),
                  let destinationStep = try? RecipeStep(destinationRecord.content),
                  let sourceNode = nodes.first(where: { $0.label == sourceStep }),
                  let destinationNode = nodes.first(where: { $0.label == destinationStep }) else {
                return nil
            }

            return Edge<RecipeStepNode>(source: sourceNode,
                                        destination: destinationNode)
        }.compactMap({ $0 })
        let graph = try RecipeStepGraph(nodes: nodes, edges: edges)

        let recipe = try Recipe(
            name: recipeRecord.name,
            ingredients: ingredientRecords
                .compactMap { try? RecipeIngredient(name: $0.name, quantity: Quantity(from: $0.quantity)) },
            graph: graph)

        recipe.id = recipeRecord.id
        recipe.recipeCategoryId = categoryRecord.id

        guard let id = recipeRecord.id else {
            XCTFail("Recipes should have a non-nil ID after insertion into database")
            return
        }

        let fetchedRecipe = try appDatabase.fetchRecipe(id: id)

        XCTAssertEqual(fetchedRecipe, recipe)
        let fetchedGraph = fetchedRecipe?.stepGraph
        // TODO: Fix
//        XCTAssertEqual(fetchedGraph, recipe.stepGraph)
    }

    func testFetchIngredient() throws {
        var categoryRecord = IngredientCategoryRecord(name: "Dairy")
        var ingredientRecord = IngredientRecord(name: "Egg", quantityType: .count)
        var batchRecords = [
            IngredientBatchRecord(expiryDate: .today,
                                  quantity: .count(12)),
            IngredientBatchRecord(expiryDate: Date(timeIntervalSinceNow: 60 * 60 * 24).startOfDay,
                                  quantity: .count(13)),
            IngredientBatchRecord(quantity: .count(14))
        ]

        try dbWriter.write { db in
            try categoryRecord.insert(db)

            ingredientRecord.ingredientCategoryId = categoryRecord.id

            try ingredientRecord.insert(db)

            for index in 0..<batchRecords.count {
                batchRecords[index].ingredientId = ingredientRecord.id
                try batchRecords[index].insert(db)
            }
        }

        let ingredient = try Ingredient(name: ingredientRecord.name,
                                        type: .count,
                                        batches: batchRecords.map {
                                            IngredientBatch(
                                                quantity: try Quantity(from: $0.quantity),
                                                expiryDate: $0.expiryDate)
                                        })
        ingredient.id = ingredientRecord.id
        ingredient.ingredientCategoryId = categoryRecord.id

        guard let id = ingredientRecord.id else {
            XCTFail("Ingredients should have a non-nil ID after insertion into database")
            return
        }

        try XCTAssertEqual(appDatabase.fetchIngredient(id: id), ingredient)
    }

    func testFetchRecipeCategoryByName() throws {
        var categoryRecord = RecipeCategoryRecord(name: "American")

        try dbWriter.write { db in
            try categoryRecord.insert(db)
        }

        let recipeCategory = try RecipeCategory(name: "American")
        let fetchedRecipeCategory = try appDatabase.fetchRecipeCategory(name: "American")

        XCTAssertEqual(fetchedRecipeCategory?.name, recipeCategory.name)
    }

    func testFetchRecipeByOnlineId(onlineId: String) throws {
        var recipeRecord = RecipeRecord(onlineId: "1", name: "Pancakes", servings: 1)

        try dbWriter.write { db in
            try recipeRecord.insert(db)
        }

        let recipe = try Recipe(name: "Pancakes", onlineId: "1", servings: 1)
        let fetchedRecipe = try appDatabase.fetchRecipe(onlineId: "1")

        XCTAssertEqual(recipe, fetchedRecipe)
    }
}
