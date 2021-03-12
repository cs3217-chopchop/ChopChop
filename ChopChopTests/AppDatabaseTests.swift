// swiftlint:disable type_body_length function_body_length
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

    func testDatabaseSchema_recipeSchema() throws {
        try dbWriter.read { db in
            try XCTAssertTrue(db.tableExists("recipe"))
            let columns = try db.columns(in: "recipe")
            let columnNames = Set(columns.map { $0.name })

            XCTAssertEqual(columnNames, ["id", "name"])
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

            XCTAssertEqual(columnNames, ["id", "name"])
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

    func testSaveRecipe_insertsInvalidName_throwsError() throws {
        var recipe = Recipe(name: "")
        var ingredients: [RecipeIngredient] = []
        var steps: [RecipeStep] = []

        try XCTAssertThrowsError(appDatabase.saveRecipe(&recipe, ingredients: &ingredients, steps: &steps))
    }

    func testSaveRecipe_insertsValidIngredients_success() throws {
        var recipe = Recipe(name: "Pancakes")
        var ingredients = [
            RecipeIngredient(name: "Flour", quantity: .mass(0.120)),
            RecipeIngredient(name: "Baking Powder", quantity: .volume(0.007_5)),
            RecipeIngredient(name: "Salt", quantity: .volume(0.000_312_5)),
            RecipeIngredient(name: "Milk", quantity: .volume(0.250)),
            RecipeIngredient(name: "Egg", quantity: .count(1)),
            RecipeIngredient(name: "Sugar", quantity: .volume(0.015))
        ]
        var steps: [RecipeStep] = []

        try appDatabase.saveRecipe(&recipe, ingredients: &ingredients, steps: &steps)

        try dbWriter.read { db in
            try XCTAssertTrue(recipe.exists(db))

            for ingredient in ingredients {
                try XCTAssertTrue(ingredient.exists(db))
            }
        }
    }

    func testSaveRecipe_insertsDuplicateIngredientsDifferentRecipes_success() throws {
        var pancakeRecipe = Recipe(name: "Pancakes")
        var pancakeIngredients = [
            RecipeIngredient(name: "Flour", quantity: .mass(0.120)),
            RecipeIngredient(name: "Baking Powder", quantity: .volume(0.007_5)),
            RecipeIngredient(name: "Salt", quantity: .volume(0.000_312_5)),
            RecipeIngredient(name: "Milk", quantity: .volume(0.250)),
            RecipeIngredient(name: "Egg", quantity: .count(1)),
            RecipeIngredient(name: "Sugar", quantity: .volume(0.015))
        ]
        var scrambledEggRecipe = Recipe(name: "Scrambled Eggs")
        var scrambledEggIngredients = [
            RecipeIngredient(name: "Egg", quantity: .count(3)),
            RecipeIngredient(name: "Milk", quantity: .volume(0.03)),
            RecipeIngredient(name: "Butter", quantity: .volume(0.01)),
            RecipeIngredient(name: "Salt", quantity: .volume(0.001_25)),
            RecipeIngredient(name: "Pepper", quantity: .volume(0.002_5))
        ]
        var steps: [RecipeStep] = []

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
        var recipe = Recipe(name: "Pancakes")
        var ingredients = [
            RecipeIngredient(name: "Flour", quantity: .mass(0.120)),
            RecipeIngredient(name: "Baking Powder", quantity: .volume(0.007_5)),
            RecipeIngredient(name: "Salt", quantity: .volume(0.000_312_5)),
            RecipeIngredient(name: "Milk", quantity: .volume(0.250)),
            RecipeIngredient(name: "Egg", quantity: .count(1)),
            RecipeIngredient(name: "Sugar", quantity: .volume(0.015)),
            RecipeIngredient(name: "", quantity: .count(0))
        ]
        var steps: [RecipeStep] = []

        try XCTAssertThrowsError(appDatabase.saveRecipe(&recipe, ingredients: &ingredients, steps: &steps))
    }

    func testSaveRecipe_insertsDuplicateIngredients_throwsError() throws {
        var recipe = Recipe(name: "Pancakes")
        var ingredients = [
            RecipeIngredient(name: "Flour", quantity: .mass(0.120)),
            RecipeIngredient(name: "Baking Powder", quantity: .volume(0.007_5)),
            RecipeIngredient(name: "Salt", quantity: .volume(0.000_312_5)),
            RecipeIngredient(name: "Milk", quantity: .volume(0.250)),
            RecipeIngredient(name: "Egg", quantity: .count(1)),
            RecipeIngredient(name: "Sugar", quantity: .volume(0.015)),
            RecipeIngredient(name: "Sugar", quantity: .volume(0.015))
        ]
        var steps: [RecipeStep] = []

        try XCTAssertThrowsError(appDatabase.saveRecipe(&recipe, ingredients: &ingredients, steps: &steps))
    }

    func testSaveRecipe_insertsValidSteps_success() throws {
        var recipe = Recipe(name: "Pancakes")
        var ingredients: [RecipeIngredient] = []
        var steps = [
            RecipeStep(index: 1, content: """
                In a large bowl, mix dry ingredients together until well-blended.
                """),
            RecipeStep(index: 2, content: """
                Add milk and mix well until smooth.
                """),
            RecipeStep(index: 3, content: """
                Separate the egg, placing the whites in a medium bowl and the yolks in the batter. Mix well.
                """),
            RecipeStep(index: 4, content: """
                Beat whites until stiff and then fold into batter gently.
                """),
            RecipeStep(index: 5, content: """
                Pour ladles of the mixture into a non-stick pan, one at a time.
                """),
            RecipeStep(index: 6, content: """
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
        var recipe = Recipe(name: "Pancakes")
        var ingredients: [RecipeIngredient] = []
        var steps = [
            RecipeStep(index: 1, content: """
                In a large bowl, mix dry ingredients together until well-blended.
                """),
            RecipeStep(index: 2, content: """
                Add milk and mix well until smooth.
                """),
            RecipeStep(index: 3, content: """
                Separate the egg, placing the whites in a medium bowl and the yolks in the batter. Mix well.
                """),
            RecipeStep(index: 4, content: """
                Beat whites until stiff and then fold into batter gently.
                """),
            RecipeStep(index: 5, content: """
                Pour ladles of the mixture into a non-stick pan, one at a time.
                """),
            RecipeStep(index: 6, content: """
                Cook until the edges are dry and bubbles appear on surface. Flip; cook until golden. Yields 12 to 14 \
                pancakes.
                """),
            RecipeStep(index: 7, content: "")
        ]

        try XCTAssertThrowsError(appDatabase.saveRecipe(&recipe, ingredients: &ingredients, steps: &steps))
    }

    func testSaveRecipe_insertsDuplicateStepIndex_throwsError() throws {
        var recipe = Recipe(name: "Pancakes")
        var ingredients: [RecipeIngredient] = []
        var steps = [
            RecipeStep(index: 1, content: """
                In a large bowl, mix dry ingredients together until well-blended.
                """),
            RecipeStep(index: 1, content: """
                Add milk and mix well until smooth.
                """),
            RecipeStep(index: 3, content: """
                Separate the egg, placing the whites in a medium bowl and the yolks in the batter. Mix well.
                """),
            RecipeStep(index: 4, content: """
                Beat whites until stiff and then fold into batter gently.
                """),
            RecipeStep(index: 5, content: """
                Pour ladles of the mixture into a non-stick pan, one at a time.
                """),
            RecipeStep(index: 6, content: """
                Cook until the edges are dry and bubbles appear on surface. Flip; cook until golden. Yields 12 to 14 \
                pancakes.
                """)
        ]

        try XCTAssertThrowsError(appDatabase.saveRecipe(&recipe, ingredients: &ingredients, steps: &steps))
    }

    func testSaveRecipe_insertsNonConsecutiveStepIndex_throwsError() throws {
        var recipe = Recipe(name: "Pancakes")
        var ingredients: [RecipeIngredient] = []
        var steps = [
            RecipeStep(index: 1, content: """
                In a large bowl, mix dry ingredients together until well-blended.
                """),
            RecipeStep(index: 3, content: """
                Add milk and mix well until smooth.
                """),
            RecipeStep(index: 4, content: """
                Separate the egg, placing the whites in a medium bowl and the yolks in the batter. Mix well.
                """),
            RecipeStep(index: 5, content: """
                Beat whites until stiff and then fold into batter gently.
                """),
            RecipeStep(index: 6, content: """
                Pour ladles of the mixture into a non-stick pan, one at a time.
                """),
            RecipeStep(index: 7, content: """
                Cook until the edges are dry and bubbles appear on surface. Flip; cook until golden. Yields 12 to 14 \
                pancakes.
                """)
        ]

        try XCTAssertThrowsError(appDatabase.saveRecipe(&recipe, ingredients: &ingredients, steps: &steps))
    }

    func testDeleteIngredients() throws {
        var recipe1 = Recipe(name: "Pancakes")
        var recipe2 = Recipe(name: "Scrambled Eggs")
        var ingredients = [
            RecipeIngredient(name: "Flour", quantity: .mass(0.120)),
            RecipeIngredient(name: "Baking Powder", quantity: .volume(0.007_5)),
            RecipeIngredient(name: "Salt", quantity: .volume(0.000_312_5)),
            RecipeIngredient(name: "Milk", quantity: .volume(0.250)),
            RecipeIngredient(name: "Egg", quantity: .count(1)),
            RecipeIngredient(name: "Sugar", quantity: .volume(0.015))
        ]
        var steps = [
            RecipeStep(index: 1, content: """
                In a large bowl, mix dry ingredients together until well-blended.
                """),
            RecipeStep(index: 2, content: """
                Add milk and mix well until smooth.
                """),
            RecipeStep(index: 3, content: """
                Separate the egg, placing the whites in a medium bowl and the yolks in the batter. Mix well.
                """),
            RecipeStep(index: 4, content: """
                Beat whites until stiff and then fold into batter gently.
                """),
            RecipeStep(index: 5, content: """
                Pour ladles of the mixture into a non-stick pan, one at a time.
                """),
            RecipeStep(index: 6, content: """
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

        try XCTAssertEqual(dbWriter.read(Recipe.fetchCount), 1)
    }

    func testDeleteAllRecipes() throws {
        var recipe1 = Recipe(name: "Pancakes")
        var recipe2 = Recipe(name: "Scrambled Eggs")

        try dbWriter.write { db in
            try recipe1.insert(db)
            try recipe2.insert(db)
        }

        try appDatabase.deleteAllRecipes()

        try XCTAssertEqual(dbWriter.read(Recipe.fetchCount), 0)
    }

    func testDeleteAllIngredients() throws {
        var ingredient1 = Recipe(name: "Salt")
        var ingredient2 = Recipe(name: "Sugar")

        try dbWriter.write { db in
            try ingredient1.insert(db)
            try ingredient2.insert(db)
        }

        try appDatabase.deleteAllIngredients()

        try XCTAssertEqual(dbWriter.read(Ingredient.fetchCount), 0)
    }
}
