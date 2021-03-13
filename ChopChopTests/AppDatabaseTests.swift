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
        var recipe = RecipeRecord(name: "")
        var ingredients: [RecipeIngredientRecord] = []
        var steps: [RecipeStepRecord] = []

        try XCTAssertThrowsError(appDatabase.saveRecipe(&recipe, ingredients: &ingredients, steps: &steps))
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

    func testDeleteIngredients() throws {
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

    func testFetchRecipe() throws {
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
                            name: recipeRecord.name,
                            ingredients: ingredientRecords.reduce(into: [:]) {
                                $0[$1.name] = $1.quantity
                            },
                            steps: stepRecords.sorted(by: { $0.index < $1.index }).map { $0.content })

        try XCTAssertEqual(appDatabase.fetchRecipe(recipeRecord), recipe)
    }

    func testFetchIngredient() throws {
        var ingredientRecord = IngredientRecord(name: "Egg")
        var setRecords = [
            IngredientSetRecord(expiryDate: Calendar.current.startOfDay(for: Date()),
                                quantity: .count(12)),
            IngredientSetRecord(expiryDate: Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: 60 * 60 * 24)),
                                quantity: .count(13)),
            IngredientSetRecord(quantity: .count(14))
        ]

        try dbWriter.write { db in
            try ingredientRecord.insert(db)

            for index in 0..<setRecords.count {
                setRecords[index].ingredientId = ingredientRecord.id
                try setRecords[index].insert(db)
            }
        }

        let ingredient = Ingredient(id: ingredientRecord.id,
                                    name: ingredientRecord.name,
                                    sets: setRecords.reduce(into: [:]) {
                                        $0[$1.expiryDate] = $1.quantity
                                    })

        try XCTAssertEqual(appDatabase.fetchIngredient(ingredientRecord), ingredient)
    }
}
