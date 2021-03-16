// swiftlint:disable type_body_length function_body_length file_length
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

    func testDatabaseSchema_recipeSchema() throws {
        try dbWriter.read { db in
            try XCTAssertTrue(db.tableExists("recipe"))
            let columns = try db.columns(in: "recipe")
            let columnNames = Set(columns.map { $0.name })

            XCTAssertEqual(columnNames, ["id", "recipeCategoryId", "name"])
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

    func testDatabaseSchema_recipeStepSchema() throws {
        try dbWriter.read { db in
            try XCTAssertTrue(db.tableExists("recipeStep"))
            let columns = try db.columns(in: "recipeStep")
            let columnNames = Set(columns.map { $0.name })

            XCTAssertEqual(columnNames, ["id", "recipeId", "index", "content"])
        }
    }

    func testDatabaseSchema_ingredientSchema() throws {
        try dbWriter.read { db in
            try XCTAssertTrue(db.tableExists("ingredient"))
            let columns = try db.columns(in: "ingredient")
            let columnNames = Set(columns.map { $0.name })

            XCTAssertEqual(columnNames, ["id", "ingredientCategoryId", "name"])
        }
    }

    func testDatabaseSchema_ingredientSetSchema() throws {
        try dbWriter.read { db in
            try XCTAssertTrue(db.tableExists("ingredientSet"))
            let columns = try db.columns(in: "ingredientSet")
            let columnNames = Set(columns.map { $0.name })

            XCTAssertEqual(columnNames, ["id", "ingredientId", "expiryDate", "quantity"])
        }
    }

    // MARK: - Recipe CRUD Tests

    func testSaveRecipe_insertsInvalidName_throwsError() throws {
        var recipe = RecipeRecord(name: "")

        try XCTAssertThrowsError(appDatabase.saveRecipe(&recipe))
    }

    func testSaveRecipe_insertsDuplicateName_throwsError() throws {
        var recipe1 = RecipeRecord(name: "Pancakes")
        var recipe2 = RecipeRecord(name: "Pancakes")

        try appDatabase.saveRecipe(&recipe1)
        try XCTAssertThrowsError(appDatabase.saveRecipe(&recipe2))
    }

    func testSaveRecipe_insertsValidIngredients_success() throws {
        var recipe = RecipeRecord(name: "Pancakes")
        var ingredients = [
            RecipeIngredientRecord(name: "Flour", quantity: .mass(0.120)),
            RecipeIngredientRecord(name: "Baking Powder", quantity: .volume(0.007_5)),
            RecipeIngredientRecord(name: "Salt", quantity: .volume(0.000_312_5)),
            RecipeIngredientRecord(name: "Milk", quantity: .volume(0.250)),
            RecipeIngredientRecord(name: "Egg", quantity: .count(1)),
            RecipeIngredientRecord(name: "Sugar", quantity: .volume(0.015))
        ]
        var steps: [RecipeStepRecord] = []

        try appDatabase.saveRecipe(&recipe, ingredients: &ingredients, steps: &steps)

        try dbWriter.read { db in
            try XCTAssertTrue(recipe.exists(db))

            for ingredient in ingredients {
                try XCTAssertTrue(ingredient.exists(db))
            }
        }
    }

    func testSaveRecipe_insertsDuplicateIngredientsDifferentRecipes_success() throws {
        var pancakeRecipe = RecipeRecord(name: "Pancakes")
        var pancakeIngredients = [
            RecipeIngredientRecord(name: "Flour", quantity: .mass(0.120)),
            RecipeIngredientRecord(name: "Baking Powder", quantity: .volume(0.007_5)),
            RecipeIngredientRecord(name: "Salt", quantity: .volume(0.000_312_5)),
            RecipeIngredientRecord(name: "Milk", quantity: .volume(0.250)),
            RecipeIngredientRecord(name: "Egg", quantity: .count(1)),
            RecipeIngredientRecord(name: "Sugar", quantity: .volume(0.015))
        ]
        var scrambledEggRecipe = RecipeRecord(name: "Scrambled Eggs")
        var scrambledEggIngredients = [
            RecipeIngredientRecord(name: "Egg", quantity: .count(3)),
            RecipeIngredientRecord(name: "Milk", quantity: .volume(0.03)),
            RecipeIngredientRecord(name: "Butter", quantity: .volume(0.01)),
            RecipeIngredientRecord(name: "Salt", quantity: .volume(0.001_25)),
            RecipeIngredientRecord(name: "Pepper", quantity: .volume(0.002_5))
        ]
        var steps: [RecipeStepRecord] = []

        try appDatabase.saveRecipe(&pancakeRecipe, ingredients: &pancakeIngredients, steps: &steps)
        try appDatabase.saveRecipe(&scrambledEggRecipe, ingredients: &scrambledEggIngredients, steps: &steps)

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
        var recipe = RecipeRecord(name: "Pancakes")
        var ingredients = [
            RecipeIngredientRecord(name: "Flour", quantity: .mass(0.120)),
            RecipeIngredientRecord(name: "Baking Powder", quantity: .volume(0.007_5)),
            RecipeIngredientRecord(name: "Salt", quantity: .volume(0.000_312_5)),
            RecipeIngredientRecord(name: "Milk", quantity: .volume(0.250)),
            RecipeIngredientRecord(name: "Egg", quantity: .count(1)),
            RecipeIngredientRecord(name: "Sugar", quantity: .volume(0.015)),
            RecipeIngredientRecord(name: "", quantity: .count(0))
        ]
        var steps: [RecipeStepRecord] = []

        try XCTAssertThrowsError(appDatabase.saveRecipe(&recipe, ingredients: &ingredients, steps: &steps))
    }

    func testSaveRecipe_insertsDuplicateIngredients_throwsError() throws {
        var recipe = RecipeRecord(name: "Pancakes")
        var ingredients = [
            RecipeIngredientRecord(name: "Flour", quantity: .mass(0.120)),
            RecipeIngredientRecord(name: "Baking Powder", quantity: .volume(0.007_5)),
            RecipeIngredientRecord(name: "Salt", quantity: .volume(0.000_312_5)),
            RecipeIngredientRecord(name: "Milk", quantity: .volume(0.250)),
            RecipeIngredientRecord(name: "Egg", quantity: .count(1)),
            RecipeIngredientRecord(name: "Sugar", quantity: .volume(0.015)),
            RecipeIngredientRecord(name: "Sugar", quantity: .volume(0.015))
        ]
        var steps: [RecipeStepRecord] = []

        try XCTAssertThrowsError(appDatabase.saveRecipe(&recipe, ingredients: &ingredients, steps: &steps))
    }

    func testSaveRecipe_insertsValidSteps_success() throws {
        var recipe = RecipeRecord(name: "Pancakes")
        var ingredients: [RecipeIngredientRecord] = []
        var steps = [
            RecipeStepRecord(index: 1, content: """
                In a large bowl, mix dry ingredients together until well-blended.
                """),
            RecipeStepRecord(index: 2, content: """
                Add milk and mix well until smooth.
                """),
            RecipeStepRecord(index: 3, content: """
                Separate the egg, placing the whites in a medium bowl and the yolks in the batter. Mix well.
                """),
            RecipeStepRecord(index: 4, content: """
                Beat whites until stiff and then fold into batter gently.
                """),
            RecipeStepRecord(index: 5, content: """
                Pour ladles of the mixture into a non-stick pan, one at a time.
                """),
            RecipeStepRecord(index: 6, content: """
                Cook until the edges are dry and bubbles appear on surface. Flip; cook until golden. Yields 12 to 14 \
                pancakes.
                """)
        ]

        try appDatabase.saveRecipe(&recipe, ingredients: &ingredients, steps: &steps)

        try dbWriter.read { db in
            try XCTAssertTrue(recipe.exists(db))

            for step in steps {
                try XCTAssertTrue(step.exists(db))
            }
        }
    }

    func testSaveRecipe_insertsInvalidSteps_throwsError() throws {
        var recipe = RecipeRecord(name: "Pancakes")
        var ingredients: [RecipeIngredientRecord] = []
        var steps = [
            RecipeStepRecord(index: 1, content: """
                In a large bowl, mix dry ingredients together until well-blended.
                """),
            RecipeStepRecord(index: 2, content: """
                Add milk and mix well until smooth.
                """),
            RecipeStepRecord(index: 3, content: """
                Separate the egg, placing the whites in a medium bowl and the yolks in the batter. Mix well.
                """),
            RecipeStepRecord(index: 4, content: """
                Beat whites until stiff and then fold into batter gently.
                """),
            RecipeStepRecord(index: 5, content: """
                Pour ladles of the mixture into a non-stick pan, one at a time.
                """),
            RecipeStepRecord(index: 6, content: """
                Cook until the edges are dry and bubbles appear on surface. Flip; cook until golden. Yields 12 to 14 \
                pancakes.
                """),
            RecipeStepRecord(index: 7, content: "")
        ]

        try XCTAssertThrowsError(appDatabase.saveRecipe(&recipe, ingredients: &ingredients, steps: &steps))
    }

    func testSaveRecipe_insertsDuplicateStepIndex_throwsError() throws {
        var recipe = RecipeRecord(name: "Pancakes")
        var ingredients: [RecipeIngredientRecord] = []
        var steps = [
            RecipeStepRecord(index: 1, content: """
                In a large bowl, mix dry ingredients together until well-blended.
                """),
            RecipeStepRecord(index: 1, content: """
                Add milk and mix well until smooth.
                """),
            RecipeStepRecord(index: 3, content: """
                Separate the egg, placing the whites in a medium bowl and the yolks in the batter. Mix well.
                """),
            RecipeStepRecord(index: 4, content: """
                Beat whites until stiff and then fold into batter gently.
                """),
            RecipeStepRecord(index: 5, content: """
                Pour ladles of the mixture into a non-stick pan, one at a time.
                """),
            RecipeStepRecord(index: 6, content: """
                Cook until the edges are dry and bubbles appear on surface. Flip; cook until golden. Yields 12 to 14 \
                pancakes.
                """)
        ]

        try XCTAssertThrowsError(appDatabase.saveRecipe(&recipe, ingredients: &ingredients, steps: &steps))
    }

    func testSaveRecipe_insertsNonConsecutiveStepIndex_throwsError() throws {
        var recipe = RecipeRecord(name: "Pancakes")
        var ingredients: [RecipeIngredientRecord] = []
        var steps = [
            RecipeStepRecord(index: 1, content: """
                In a large bowl, mix dry ingredients together until well-blended.
                """),
            RecipeStepRecord(index: 3, content: """
                Add milk and mix well until smooth.
                """),
            RecipeStepRecord(index: 4, content: """
                Separate the egg, placing the whites in a medium bowl and the yolks in the batter. Mix well.
                """),
            RecipeStepRecord(index: 5, content: """
                Beat whites until stiff and then fold into batter gently.
                """),
            RecipeStepRecord(index: 6, content: """
                Pour ladles of the mixture into a non-stick pan, one at a time.
                """),
            RecipeStepRecord(index: 7, content: """
                Cook until the edges are dry and bubbles appear on surface. Flip; cook until golden. Yields 12 to 14 \
                pancakes.
                """)
        ]

        try XCTAssertThrowsError(appDatabase.saveRecipe(&recipe, ingredients: &ingredients, steps: &steps))
    }

    func testDeleteRecipes() throws {
        var recipe1 = RecipeRecord(name: "Pancakes")
        var recipe2 = RecipeRecord(name: "Scrambled Eggs")
        var ingredients = [
            RecipeIngredientRecord(name: "Flour", quantity: .mass(0.120)),
            RecipeIngredientRecord(name: "Baking Powder", quantity: .volume(0.007_5)),
            RecipeIngredientRecord(name: "Salt", quantity: .volume(0.000_312_5)),
            RecipeIngredientRecord(name: "Milk", quantity: .volume(0.250)),
            RecipeIngredientRecord(name: "Egg", quantity: .count(1)),
            RecipeIngredientRecord(name: "Sugar", quantity: .volume(0.015))
        ]
        var steps = [
            RecipeStepRecord(index: 1, content: """
                In a large bowl, mix dry ingredients together until well-blended.
                """),
            RecipeStepRecord(index: 2, content: """
                Add milk and mix well until smooth.
                """),
            RecipeStepRecord(index: 3, content: """
                Separate the egg, placing the whites in a medium bowl and the yolks in the batter. Mix well.
                """),
            RecipeStepRecord(index: 4, content: """
                Beat whites until stiff and then fold into batter gently.
                """),
            RecipeStepRecord(index: 5, content: """
                Pour ladles of the mixture into a non-stick pan, one at a time.
                """),
            RecipeStepRecord(index: 6, content: """
                Cook until the edges are dry and bubbles appear on surface. Flip; cook until golden. Yields 12 to 14 \
                pancakes.
                """)
        ]

        try dbWriter.write { db in
            try recipe1.insert(db)
            try recipe2.insert(db)

            for index in 0..<ingredients.count {
                ingredients[index].recipeId = recipe1.id
                try ingredients[index].insert(db)
            }

            for index in 0..<steps.count {
                steps[index].recipeId = recipe1.id
                try steps[index].insert(db)
            }
        }

        guard let id = recipe1.id else {
            XCTFail("Recipes should have a non-nil ID after insertion into database")
            return
        }

        try appDatabase.deleteRecipes(ids: [id])

        try dbWriter.read { db in
            try XCTAssertFalse(recipe1.exists(db))

            // Deleting recipes should also delete their associated ingredients and steps
            for ingredient in ingredients {
                try XCTAssertFalse(ingredient.exists(db))
            }

            for step in steps {
                try XCTAssertFalse(step.exists(db))
            }
        }

        try XCTAssertEqual(dbWriter.read(RecipeRecord.fetchCount), 1)
    }

    func testDeleteAllRecipes() throws {
        var recipe1 = RecipeRecord(name: "Pancakes")
        var recipe2 = RecipeRecord(name: "Scrambled Eggs")

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

    func testDeleteRecipeCategory_recipesRemaining_throwsError() throws {
        var category = RecipeCategoryRecord(name: "American")
        var recipe = RecipeRecord(name: "Pancakes")

        try dbWriter.write { db in
            try category.insert(db)

            recipe.recipeCategoryId = category.id

            try recipe.insert(db)
        }

        guard let id = category.id else {
            XCTFail("Recipe categories should have a non-nil ID after insertion into database")
            return
        }

        try XCTAssertThrowsError(appDatabase.deleteRecipeCategories(ids: [id]))
    }

    func testSaveRecipe_insertsDefaultCategoryNil_success() throws {
        var recipe = RecipeRecord(name: "Pancakes")

        try appDatabase.saveRecipe(&recipe)

        XCTAssertNil(recipe.recipeCategoryId)
    }

    func testSaveRecipe_insertsExistingCategory_success() throws {
        var category = RecipeCategoryRecord(name: "American")

        try dbWriter.write { db in
            try category.insert(db)
        }

        var recipe = RecipeRecord(recipeCategoryId: category.id, name: "Pancakes")

        try appDatabase.saveRecipe(&recipe)

        XCTAssertEqual(recipe.recipeCategoryId, recipe.id)
    }

    func testSaveRecipe_insertsMissingCategory_success() throws {
        var recipe = RecipeRecord(recipeCategoryId: 1, name: "Pancakes")

        try XCTAssertThrowsError(appDatabase.saveRecipe(&recipe))
    }

    // MARK: - Ingredient CRUD Tests

    func testSaveIngredient_insertsInvalidName_throwsError() throws {
        var ingredient = IngredientRecord(name: "")

        try XCTAssertThrowsError(appDatabase.saveIngredient(&ingredient))
    }

    func testSaveIngredient_insertsDuplicateName_throwsError() throws {
        var ingredient1 = IngredientRecord(name: "Egg")
        var ingredient2 = IngredientRecord(name: "Egg")

        try appDatabase.saveIngredient(&ingredient1)
        try XCTAssertThrowsError(appDatabase.saveIngredient(&ingredient2))
    }

    func testSaveIngredient_insertsValidSets_success() throws {
        var ingredient = IngredientRecord(name: "Egg")
        var batches = [
            IngredientBatchRecord(
                expiryDate: Calendar.current.startOfDay(for: Date()),
                quantity: .count(12)),
            IngredientBatchRecord(
                expiryDate: Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: 60 * 60 * 24)),
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

    func testSaveIngredient_insertsInvalidSets_throwsError() throws {
        var ingredient = IngredientRecord(name: "Egg")
        var batches = [
            IngredientBatchRecord(
                expiryDate: Calendar.current.startOfDay(for: Date()),
                quantity: .count(12)),
            IngredientBatchRecord(
                expiryDate: Calendar.current.startOfDay(for: Date()),
                quantity: .count(13))
        ]

        try XCTAssertThrowsError(appDatabase.saveIngredient(&ingredient, batches: &batches))
    }

    func testDeleteIngredients() throws {
        var ingredient1 = IngredientRecord(name: "Egg")
        var ingredient2 = IngredientRecord(name: "Salt")
        var ingredient3 = IngredientRecord(name: "Sugar")
        var sets = [
            IngredientBatchRecord(
                expiryDate: Calendar.current.startOfDay(for: Date()),
                quantity: .count(12)),
            IngredientBatchRecord(
                expiryDate: Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: 60 * 60 * 24)),
                quantity: .count(13)),
            IngredientBatchRecord(quantity: .count(14))
        ]

        try dbWriter.write { db in
            try ingredient1.insert(db)
            try ingredient2.insert(db)
            try ingredient3.insert(db)

            for index in 0..<sets.count {
                sets[index].ingredientId = ingredient1.id
                try sets[index].insert(db)
            }
        }

        guard let id = ingredient1.id else {
            XCTFail("Ingredients should have a non-nil ID after insertion into database")
            return
        }

        try appDatabase.deleteIngredients(ids: [id])

        try dbWriter.read { db in
            try XCTAssertFalse(ingredient1.exists(db))

            // Deleting ingredients should also delete their associated sets
            for set in sets {
                try XCTAssertFalse(set.exists(db))
            }
        }

        try XCTAssertEqual(dbWriter.read(IngredientRecord.fetchCount), 2)
    }

    func testDeleteAllIngredients() throws {
        var ingredient1 = RecipeRecord(name: "Salt")
        var ingredient2 = RecipeRecord(name: "Sugar")

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

    func testDeleteIngredientCategory_recipesRemaining_throwsError() throws {
        var category = IngredientCategoryRecord(name: "Spices")
        var ingredient = IngredientRecord(name: "Pepper")

        try dbWriter.write { db in
            try category.insert(db)

            ingredient.ingredientCategoryId = category.id

            try ingredient.insert(db)
        }

        guard let id = category.id else {
            XCTFail("Recipe categories should have a non-nil ID after insertion into database")
            return
        }

        try XCTAssertThrowsError(appDatabase.deleteIngredientCategories(ids: [id]))
    }

    func testSaveIngredient_insertsDefaultCategoryNil_success() throws {
        var ingredient = IngredientRecord(name: "Pepper")

        try appDatabase.saveIngredient(&ingredient)

        XCTAssertNil(ingredient.ingredientCategoryId)
    }

    func testSaveIngredient_insertsExistingCategory_success() throws {
        var category = IngredientCategoryRecord(name: "Spices")

        try dbWriter.write { db in
            try category.insert(db)
        }

        var ingredient = IngredientRecord(ingredientCategoryId: category.id, name: "Pepper")

        try appDatabase.saveIngredient(&ingredient)

        XCTAssertEqual(ingredient.ingredientCategoryId, category.id)
    }

    func testSaveIngredient_insertsMissingCategory_success() throws {
        var ingredient = IngredientRecord(ingredientCategoryId: 1, name: "Pepper")

        try XCTAssertThrowsError(appDatabase.saveIngredient(&ingredient))
    }

    // MARK: - Recipes Publisher Tests

    func testRecipesOrderedByNamePublisher_publishesWellOrderedRecipes() throws {
        var recipe1 = RecipeRecord(name: "Scrambled Eggs")
        var recipe2 = RecipeRecord(name: "Pancakes")

        try dbWriter.write { db in
            try recipe1.insert(db)
            try recipe2.insert(db)
        }

        let exp = expectation(description: "Recipes")
        var recipes: [RecipeRecord]?
        let cancellable = appDatabase.recipesOrderedByNamePublisher().sink { completion in
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

    func testRecipesOrderedByNamePublisher_publishesRightOnSubscription() throws {
        var recipes: [RecipeRecord]?
        _ = appDatabase.recipesOrderedByNamePublisher().sink { completion in
            if case let .failure(error) = completion {
                XCTFail("Unexpected error \(error)")
            }
        } receiveValue: {
            recipes = $0
        }

        XCTAssertNotNil(recipes)
    }

    func testRecipesFilteredByCategoryOrderedByNamePublisher_publishesFilteredWellOrderedRecipes() throws {
        var category1 = RecipeCategoryRecord(name: "American")
        var category2 = RecipeCategoryRecord(name: "Japanese")

        var recipe1 = RecipeRecord(name: "Scrambled Eggs")
        var recipe2 = RecipeRecord(name: "Pancakes")
        var recipe3 = RecipeRecord(name: "Miso Soup")
        var recipe4 = RecipeRecord(name: "Oyakodon")

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
        let cancellable = appDatabase.recipesFilteredByCategoryOrderedByNamePublisher(ids: [id]).sink { completion in
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

    func testRecipesFilteredByCategoryOrderedByNamePublisher_publishesRightOnSubscription() throws {
        var recipes: [RecipeRecord]?
        _ = appDatabase.recipesFilteredByCategoryOrderedByNamePublisher(ids: []).sink { completion in
            if case let .failure(error) = completion {
                XCTFail("Unexpected error \(error)")
            }
        } receiveValue: {
            recipes = $0
        }

        XCTAssertNotNil(recipes)
    }

    // MARK: - Ingredients Publisher Tests

    func testIngredientsOrderedByNamePublisher_publishesWellOrderedIngredients() throws {
        var ingredient1 = IngredientRecord(name: "Sugar")
        var ingredient2 = IngredientRecord(name: "Salt")

        try dbWriter.write { db in
            try ingredient1.insert(db)
            try ingredient2.insert(db)
        }

        let exp = expectation(description: "Ingredients")
        var ingredients: [IngredientRecord]?
        let cancellable = appDatabase.ingredientsOrderedByNamePublisher().sink { completion in
            if case let .failure(error) = completion {
                XCTFail("Unexpected error \(error)")
            }
        } receiveValue: {
            ingredients = $0
            exp.fulfill()
        }

        withExtendedLifetime(cancellable) {
            waitForExpectations(timeout: 1, handler: nil)
        }

        XCTAssertEqual(ingredients, [ingredient2, ingredient1])
    }

    func testIngredientsOrderedByNamePublisher_publishesRightOnSubscription() throws {
        var ingredients: [IngredientRecord]?
        _ = appDatabase.ingredientsOrderedByNamePublisher().sink { completion in
            if case let .failure(error) = completion {
                XCTFail("Unexpected error \(error)")
            }
        } receiveValue: {
            ingredients = $0
        }

        XCTAssertNotNil(ingredients)
    }

    func testIngredientsOrderedByExpiryDatePublisher_publishesWellOrderedIngredients() throws {
        var ingredient1 = IngredientRecord(name: "Sugar")
        var ingredient2 = IngredientRecord(name: "Salt")
        var ingredient3 = IngredientRecord(name: "Pepper")

        var sets2 = [
            IngredientBatchRecord(
                expiryDate: Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: 60 * 60 * 24)),
                quantity: .count(1))
        ]
        var sets3 = [
            IngredientBatchRecord(
                expiryDate: Calendar.current.startOfDay(for: Date()),
                quantity: .count(1))
        ]

        try dbWriter.write { db in
            try ingredient1.insert(db)
            try ingredient2.insert(db)
            try ingredient3.insert(db)

            for index in 0..<sets2.count {
                sets2[index].ingredientId = ingredient2.id
                try sets2[index].insert(db)
            }

            for index in 0..<sets3.count {
                sets3[index].ingredientId = ingredient3.id
                try sets3[index].insert(db)
            }
        }

        let exp = expectation(description: "Ingredients")
        var ingredients: [IngredientRecord]?
        let cancellable = appDatabase.ingredientsOrderedByExpiryDatePublisher().sink { completion in
            if case let .failure(error) = completion {
                XCTFail("Unexpected error \(error)")
            }
        } receiveValue: {
            ingredients = $0
            exp.fulfill()
        }

        withExtendedLifetime(cancellable) {
            waitForExpectations(timeout: 1, handler: nil)
        }

        XCTAssertEqual(ingredients, [ingredient3, ingredient2, ingredient1])
    }

    func testIngredientsOrderedByExpiryDatePublisher_publishesRightOnSubscription() throws {
        var ingredients: [IngredientRecord]?
        _ = appDatabase.ingredientsOrderedByExpiryDatePublisher().sink { completion in
            if case let .failure(error) = completion {
                XCTFail("Unexpected error \(error)")
            }
        } receiveValue: {
            ingredients = $0
        }

        XCTAssertNotNil(ingredients)
    }

    func testIngredientsFilteredByCategoryOrderedByNamePublisher_publishesFilteredWellOrderedIngredients() throws {
        var category1 = IngredientCategoryRecord(name: "Spices")
        var category2 = IngredientCategoryRecord(name: "Dairy")

        var ingredient1 = IngredientRecord(name: "Sugar")
        var ingredient2 = IngredientRecord(name: "Salt")
        var ingredient3 = IngredientRecord(name: "Milk")
        var ingredient4 = IngredientRecord(name: "Egg")

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
        let cancellable = appDatabase.ingredientsFilteredByCategoryOrderedByNamePublisher(ids: [id])
            .sink { completion in
            if case let .failure(error) = completion {
                XCTFail("Unexpected error \(error)")
            }
        } receiveValue: {
            ingredients = $0
            exp.fulfill()
            }

        withExtendedLifetime(cancellable) {
            waitForExpectations(timeout: 1, handler: nil)
        }

        XCTAssertEqual(ingredients, [ingredient4, ingredient3])
    }

    func testIngredientsFilteredByCategoryOrderedByNamePublisher_publishesRightOnSubscription() throws {
        var ingredients: [IngredientRecord]?
        _ = appDatabase.ingredientsFilteredByCategoryOrderedByNamePublisher(ids: []).sink { completion in
            if case let .failure(error) = completion {
                XCTFail("Unexpected error \(error)")
            }
        } receiveValue: {
            ingredients = $0
        }

        XCTAssertNotNil(ingredients)
    }

    // MARK: - Model Fetch Tests

    func testFetchRecipe() throws {
        var categoryRecord = RecipeCategoryRecord(name: "American")
        var recipeRecord = RecipeRecord(name: "Pancakes")
        var ingredientRecords = [
            RecipeIngredientRecord(name: "Flour", quantity: .mass(0.120)),
            RecipeIngredientRecord(name: "Baking Powder", quantity: .volume(0.007_5)),
            RecipeIngredientRecord(name: "Salt", quantity: .volume(0.000_312_5)),
            RecipeIngredientRecord(name: "Milk", quantity: .volume(0.250)),
            RecipeIngredientRecord(name: "Egg", quantity: .count(1)),
            RecipeIngredientRecord(name: "Sugar", quantity: .volume(0.015))
        ]
        var stepRecords = [
            RecipeStepRecord(index: 1, content: """
                In a large bowl, mix dry ingredients together until well-blended.
                """),
            RecipeStepRecord(index: 2, content: """
                Add milk and mix well until smooth.
                """),
            RecipeStepRecord(index: 3, content: """
                Separate the egg, placing the whites in a medium bowl and the yolks in the batter. Mix well.
                """),
            RecipeStepRecord(index: 4, content: """
                Beat whites until stiff and then fold into batter gently.
                """),
            RecipeStepRecord(index: 5, content: """
                Pour ladles of the mixture into a non-stick pan, one at a time.
                """),
            RecipeStepRecord(index: 6, content: """
                Cook until the edges are dry and bubbles appear on surface. Flip; cook until golden. Yields 12 to 14 \
                pancakes.
                """)
        ]

        try dbWriter.write { db in
            try categoryRecord.insert(db)

            recipeRecord.recipeCategoryId = categoryRecord.id

            try recipeRecord.insert(db)

            for index in 0..<ingredientRecords.count {
                ingredientRecords[index].recipeId = recipeRecord.id
                try ingredientRecords[index].insert(db)
            }

            for index in 0..<stepRecords.count {
                stepRecords[index].recipeId = recipeRecord.id
                try stepRecords[index].insert(db)
            }
        }

        let recipe = Recipe(id: recipeRecord.id,
                            recipeCategoryId: categoryRecord.id,
                            name: recipeRecord.name,
                            ingredients: ingredientRecords.reduce(into: [:]) {
                                $0[$1.name] = $1.quantity
                            },
                            steps: stepRecords.sorted(by: { $0.index < $1.index }).map { $0.content })

        guard let id = recipeRecord.id else {
            XCTFail("Recipes should have a non-nil ID after insertion into database")
            return
        }

        try XCTAssertEqual(appDatabase.fetchRecipe(id: id), recipe)
    }

    func testFetchIngredient() throws {
        var categoryRecord = IngredientCategoryRecord(name: "Dairy")
        var ingredientRecord = IngredientRecord(name: "Egg")
        var batchRecords = [
            IngredientBatchRecord(
                expiryDate: Calendar.current.startOfDay(for: Date()),
                quantity: .count(12)),
            IngredientBatchRecord(
                expiryDate: Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: 60 * 60 * 24)),
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
                                        batches: batchRecords.map {
                                            IngredientBatch(quantity: $0.quantity, expiryDate: $0.expiryDate)
                                        })
        ingredient.id = ingredientRecord.id
        ingredient.ingredientCategoryId = categoryRecord.id

        guard let id = ingredientRecord.id else {
            XCTFail("Ingredients should have a non-nil ID after insertion into database")
            return
        }

        try XCTAssertEqual(appDatabase.fetchIngredient(id: id), ingredient)
    }
}