// swiftlint:disable file_length function_body_length

import Combine
import Foundation
import GRDB

struct AppDatabase {
    private let dbWriter: DatabaseWriter

    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        #if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
        #endif

        // swiftlint:disable empty_string
        migrator.registerMigration("CreateRecipeCategory") { db in
            try db.create(table: "recipeCategory") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text)
                    .notNull()
                    .unique()
                    .check { $0 != "" }
                    .collate(.localizedStandardCompare)
            }
        }

        migrator.registerMigration("CreateRecipe") { db in
            try db.create(table: "recipe") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("onlineId", .text)
                    .unique()
                    .check { $0 != "" }
                t.column("recipeCategoryId", .integer)
                    .indexed()
                    .references("recipeCategory", onDelete: .setNull)
                t.column("name", .text)
                    .notNull()
                    .unique()
                    .check { $0 != "" }
                    .collate(.localizedStandardCompare)
                t.column("servings", .double)
                    .notNull()
                    .check { $0 > 0 }
                t.column("difficulty", .integer)
                    .check { Difficulty.allCases.map { $0.rawValue }.contains($0) }
            }
        }

        migrator.registerMigration("CreateRecipeIngredient") { db in
            try db.create(table: "recipeIngredient") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("recipeId", .integer)
                    .notNull()
                    .indexed()
                    .references("recipe", onDelete: .cascade)
                t.column("name", .text)
                    .notNull()
                    .check { $0 != "" }
                t.column("quantity", .text)
                    .notNull()
                t.uniqueKey(["recipeId", "name"])
            }
        }

        migrator.registerMigration("CreateRecipeStepGraph") { db in
            try db.create(table: "recipeStepGraph") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("recipeId", .integer)
                    .notNull()
                    .unique()
                    .references("recipe", onDelete: .cascade)
            }
        }

        migrator.registerMigration("CreateRecipeStep") { db in
            try db.create(table: "recipeStep") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("graphId", .integer)
                    .notNull()
                    .indexed()
                    .references("recipeStepGraph", onDelete: .cascade)
                t.column("content", .text)
                    .notNull()
                    .check { $0 != "" }
            }
        }

        migrator.registerMigration("CreateRecipeStepEdge") { db in
            try db.create(table: "recipeStepEdge") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("graphId", .integer)
                    .notNull()
                    .indexed()
                    .references("recipeStepGraph", onDelete: .cascade)
                t.column("sourceId", .integer)
                    .notNull()
                    .indexed()
                    .references("recipeStep", onDelete: .cascade)
                t.column("destinationId", .integer)
                    .notNull()
                    .indexed()
                    .references("recipeStep", onDelete: .cascade)
                t.uniqueKey(["graphId", "sourceId", "destinationId"])
            }
        }

        migrator.registerMigration("CreateIngredientCategory") { db in
            try db.create(table: "ingredientCategory") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text)
                    .notNull()
                    .unique()
                    .check { $0 != "" }
                    .collate(.localizedStandardCompare)
            }
        }

        migrator.registerMigration("CreateIngredient") { db in
            try db.create(table: "ingredient") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("ingredientCategoryId", .integer)
                    .indexed()
                    .references("ingredientCategory", onDelete: .setNull)
                t.column("name", .text)
                    .notNull()
                    .unique()
                    .check { $0 != "" }
                    .collate(.localizedStandardCompare)
                t.column("quantityType", .text)
                    .notNull()
                    .check { BaseQuantityType.allCases.map { $0.rawValue }.contains($0) }
            }
        }

        migrator.registerMigration("CreateIngredientBatch") { db in
            try db.create(table: "ingredientBatch") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("ingredientId", .integer)
                    .notNull()
                    .indexed()
                    .references("ingredient", onDelete: .cascade)
                t.column("expiryDate", .date)
                t.column("quantity", .text)
                    .notNull()
                t.uniqueKey(["ingredientId", "expiryDate"])
            }
        }
        // swiftlint:enable empty_string

        return migrator
    }

    init(_ dbWriter: DatabaseWriter) throws {
        self.dbWriter = dbWriter
        try migrator.migrate(dbWriter)
    }
}

// MARK: - Database: Preloaded Recipes
extension AppDatabase {
    func createPreloadedRecipesIfEmpty() throws {
        try dbWriter.write { db in
            if try RecipeRecord.fetchCount(db) == 0 && RecipeCategoryRecord.fetchCount(db) == 0 {
                try createPreloadedRecipes(db)
            }
        }
    }

    private func createPreloadedRecipes(_ db: Database) throws {
        var categories = [
            RecipeCategoryRecord(name: "Japanese"),
            RecipeCategoryRecord(name: "Italian"),
            RecipeCategoryRecord(name: "American"),
            RecipeCategoryRecord(name: "A Really Really Really Really Really Really Really Really Really Long Category")
        ]

        for index in categories.indices {
            try categories[index].save(db)
        }

        var recipes = [
            RecipeRecord(recipeCategoryId: categories[2].id,
                         name: "Pancakes",
                         servings: Double(Int.random(in: 1...5)),
                         difficulty: Difficulty.allCases.randomElement()),
            RecipeRecord(recipeCategoryId: categories[1].id,
                         name: "Carbonara",
                         servings: Double(Int.random(in: 1...5)),
                         difficulty: Difficulty.allCases.randomElement()),
            RecipeRecord(recipeCategoryId: categories[2].id,
                         name: "Scrambled Eggs",
                         servings: Double(Int.random(in: 1...5)),
                         difficulty: Difficulty.allCases.randomElement()),
            RecipeRecord(recipeCategoryId: categories[2].id,
                         name: "Pizza",
                         servings: Double(Int.random(in: 1...5)),
                         difficulty: Difficulty.allCases.randomElement()),
            RecipeRecord(recipeCategoryId: categories[0].id,
                         name: "Ramen",
                         servings: Double(Int.random(in: 1...5)),
                         difficulty: Difficulty.allCases.randomElement()),
            RecipeRecord(recipeCategoryId: categories[0].id,
                         name: "Katsudon",
                         servings: Double(Int.random(in: 1...5)),
                         difficulty: Difficulty.allCases.randomElement()),
            RecipeRecord(name: "Some Really Really Really Really Really Really Really Really Long Uncategorised Recipe",
                         servings: Double(Int.random(in: 1...5)))
        ]

        for index in recipes.indices {
            try recipes[index].save(db)
        }

        var ingredients = [
            RecipeIngredientRecord(recipeId: recipes[0].id, name: "Milk", quantity: .volume(500, unit: .milliliter)),
            RecipeIngredientRecord(recipeId: recipes[0].id, name: "Flour", quantity: .mass(200, unit: .gram)),
            RecipeIngredientRecord(recipeId: recipes[0].id, name: "Butter", quantity: .count(1)),
            RecipeIngredientRecord(recipeId: recipes[1].id, name: "Milk", quantity: .volume(600, unit: .milliliter)),
            RecipeIngredientRecord(recipeId: recipes[0].id, name: "Egg", quantity: .count(1)),
            RecipeIngredientRecord(recipeId: recipes[2].id, name: "Egg", quantity: .count(2)),
            RecipeIngredientRecord(recipeId: recipes[6].id, name: "Chocolate", quantity: .mass(200, unit: .gram)),
            RecipeIngredientRecord(recipeId: recipes[5].id, name: "Pork Chop", quantity: .mass(100, unit: .ounce)),
            RecipeIngredientRecord(recipeId: recipes[5].id, name: "Egg", quantity: .count(3)),
            RecipeIngredientRecord(recipeId: recipes[5].id, name: "Salt", quantity: .count(0)),
            RecipeIngredientRecord(recipeId: recipes[5].id, name: "Pepper", quantity: .count(0)),
            RecipeIngredientRecord(recipeId: recipes[5].id, name: "Oil", quantity: .volume(10, unit: .milliliter)),
            RecipeIngredientRecord(recipeId: recipes[5].id, name: "Onion", quantity: .count(3)),
            RecipeIngredientRecord(recipeId: recipes[5].id, name: "Rice", quantity: .count(3))
        ]

        for index in ingredients.indices {
            try ingredients[index].save(db)
        }

        var graphs = recipes.map { RecipeStepGraphRecord(recipeId: $0.id) }

        for index in graphs.indices {
            try graphs[index].save(db)
        }

        var steps = [
            // pancakes
            RecipeStepRecord(graphId: graphs[0].id, content: """
                In a large bowl, mix dry ingredients together until well-blended.
                """),
            RecipeStepRecord(graphId: graphs[0].id, content: """
                Add milk and mix well until smooth.
                """),
            RecipeStepRecord(graphId: graphs[0].id, content: """
                Separate the egg, placing the whites in a medium bowl and the yolks in the batter. Mix well.
                """),
            RecipeStepRecord(graphId: graphs[0].id, content: """
                Beat whites until stiff and then fold into batter gently.
                """),
            RecipeStepRecord(graphId: graphs[0].id, content: """
                Pour ladles of the mixture into a non-stick pan, one at a time.
                """),
            RecipeStepRecord(graphId: graphs[0].id, content: """
                Cook until the edges are dry and bubbles appear on surface. Flip; cook until golden. Yields 12 to 14 \
                pancakes.
                """),
            // katusdon
            RecipeStepRecord(graphId: graphs[5].id, content: """
                Gather the ingredients.
                """),
            RecipeStepRecord(graphId: graphs[5].id, content: """
                Season the pounded pork chops with salt and pepper.
                """),
            RecipeStepRecord(graphId: graphs[5].id, content: """
                In one shallow bowl, beat 1 of the eggs. Put the panko into another shallow bowl.
                """),
            RecipeStepRecord(graphId: graphs[5].id, content: """
                Add a thin, even layer of oil to a cast-iron pan or skillet over medium heat for 2 1/2 minutes.
                """),
            RecipeStepRecord(graphId: graphs[5].id, content: """
                Lay the pork chops in the hot oil and cook for 5 to 6 minutes on one side, until golden brown. \
                Flip and cook the other side for another 10 to 15 minutes, or until browned and cooked through. \
                Again, Flip and cook the other side for another 5 to 6 minutes, or until browned and cooked through. \
                Lastly, Flip and cook the other side for another 10 to 15 minutes, or until browned and cooked through.
                """),
            RecipeStepRecord(graphId: graphs[5].id, content: """
                To cook 1 serving of katsudon, put 1/4 of the soup and 1/4 of the sliced onion in a small skillet. \
                Simmer for a few minutes on medium heat. \
                Serve by placing 1 serving of steamed rice in a large rice bowl. \
                Repeat to make 3 more servings.
                """)
        ]

        for index in steps.indices {
            try steps[index].save(db)
        }

        var edges = [
            RecipeStepEdgeRecord(graphId: graphs[0].id, sourceId: steps[0].id, destinationId: steps[1].id),
            RecipeStepEdgeRecord(graphId: graphs[0].id, sourceId: steps[1].id, destinationId: steps[2].id),
            RecipeStepEdgeRecord(graphId: graphs[0].id, sourceId: steps[2].id, destinationId: steps[3].id),
            RecipeStepEdgeRecord(graphId: graphs[0].id, sourceId: steps[3].id, destinationId: steps[4].id),
            RecipeStepEdgeRecord(graphId: graphs[0].id, sourceId: steps[4].id, destinationId: steps[5].id),
            RecipeStepEdgeRecord(graphId: graphs[1].id, sourceId: steps[6].id, destinationId: steps[7].id),
            RecipeStepEdgeRecord(graphId: graphs[1].id, sourceId: steps[7].id, destinationId: steps[8].id),
            RecipeStepEdgeRecord(graphId: graphs[1].id, sourceId: steps[8].id, destinationId: steps[9].id),
            RecipeStepEdgeRecord(graphId: graphs[1].id, sourceId: steps[9].id, destinationId: steps[10].id),
            RecipeStepEdgeRecord(graphId: graphs[1].id, sourceId: steps[10].id, destinationId: steps[11].id)
        ]

        for index in edges.indices {
            try edges[index].save(db)
        }
    }
}

// MARK: - Database: Preloaded Ingredients
extension AppDatabase {
    func createPreloadedIngredientsIfEmpty() throws {
        try dbWriter.write { db in
            if try IngredientRecord.fetchCount(db) == 0 && IngredientCategoryRecord.fetchCount(db) == 0 {
                try createPreloadedIngredients(db)
            }
        }
    }

    private func createPreloadedIngredients(_ db: Database) throws {
        var categories = [
            IngredientCategoryRecord(name: "Spices"),
            IngredientCategoryRecord(name: "Dairy"),
            IngredientCategoryRecord(name: "Grains")
        ]

        for index in categories.indices {
            try categories[index].save(db)
        }

        var ingredients = [
            IngredientRecord(ingredientCategoryId: categories[0].id, name: "Pepper", quantityType: .mass),
            IngredientRecord(ingredientCategoryId: categories[0].id, name: "Cinnamon", quantityType: .mass),
            IngredientRecord(ingredientCategoryId: categories[1].id, name: "Milk", quantityType: .volume),
            IngredientRecord(ingredientCategoryId: categories[1].id, name: "Cheese", quantityType: .mass),
            IngredientRecord(ingredientCategoryId: categories[2].id, name: "Rice", quantityType: .mass),
            IngredientRecord(name: "Uncategorised Ingredient", quantityType: .count),
            IngredientRecord(ingredientCategoryId: categories[1].id, name: "Butter", quantityType: .mass),
            IngredientRecord(ingredientCategoryId: categories[1].id, name: "Egg", quantityType: .count),
            IngredientRecord(ingredientCategoryId: categories[0].id, name: "Salt", quantityType: .mass),
            IngredientRecord(ingredientCategoryId: categories[0].id, name: "Oil", quantityType: .volume)
        ]

        for index in ingredients.indices {
            try ingredients[index].save(db)
        }

        var batches = [
            IngredientBatchRecord(ingredientId: ingredients[0].id, quantity: .mass(500, unit: .gram)),
            IngredientBatchRecord(ingredientId: ingredients[1].id, quantity: .mass(200, unit: .gram)),
            IngredientBatchRecord(ingredientId: ingredients[2].id,
                                  expiryDate: .today,
                                  quantity: .volume(2, unit: .liter)),
            IngredientBatchRecord(ingredientId: ingredients[2].id,
                                  expiryDate: Date(timeIntervalSinceNow: 60 * 60 * 24 * 7).startOfDay,
                                  quantity: .volume(1.5, unit: .liter)),
            IngredientBatchRecord(ingredientId: ingredients[2].id,
                                  expiryDate: Date(timeIntervalSinceNow: 60 * 60 * 24 * 7 * 4).startOfDay,
                                  quantity: .volume(3, unit: .liter)),
            IngredientBatchRecord(ingredientId: ingredients[3].id,
                                  expiryDate: .today,
                                  quantity: .mass(1, unit: .kilogram)),
            IngredientBatchRecord(ingredientId: ingredients[4].id,
                                  expiryDate: .today,
                                  quantity: .mass(2, unit: .kilogram)),
            IngredientBatchRecord(ingredientId: ingredients[6].id,
                                  expiryDate: .today,
                                  quantity: .mass(20, unit: .gram)),
            IngredientBatchRecord(ingredientId: ingredients[6].id,
                                  expiryDate: Date(timeIntervalSinceNow: 60 * 60 * 24 * 7 * 4).startOfDay,
                                  quantity: .mass(0.05, unit: .kilogram)),
            IngredientBatchRecord(ingredientId: ingredients[7].id,
                                  expiryDate: Date(timeIntervalSinceNow: 60 * 60 * 24 * 7 * 4).startOfDay,
                                  quantity: .count(3)),
            IngredientBatchRecord(ingredientId: ingredients[8].id,
                                  expiryDate: .today,
                                  quantity: .mass(20, unit: .gram)),
            IngredientBatchRecord(ingredientId: ingredients[9].id,
                                  expiryDate: .today,
                                  quantity: .volume(20, unit: .pint))
        ]

        for index in batches.indices {
            try batches[index].save(db)
        }
    }
}

// MARK: - Database Access: Create/Update

extension AppDatabase {
    func saveRecipe(_ recipe: inout RecipeRecord) throws {
        var ingredients: [RecipeIngredientRecord] = []
        var stepGraph = RecipeStepGraph()

        try saveRecipe(&recipe, ingredients: &ingredients, stepGraph: &stepGraph)
    }

    func saveRecipe(_ recipe: inout RecipeRecord, ingredients: inout [RecipeIngredientRecord],
                    stepGraph: inout RecipeStepGraph) throws {
        try dbWriter.write { db in
            try recipe.save(db)

            let recipeIds = ingredients.compactMap { $0.recipeId }

            guard recipeIds.allSatisfy({ $0 == recipe.id }) else {
                throw DatabaseError(message: "Recipe ingredients belong to the wrong recipe.")
            }

            // Delete all ingredients that are not in the array and the existing graph
            try recipe.ingredients
                .filter(!ingredients.compactMap { $0.id }.contains(RecipeIngredientRecord.Columns.id))
                .deleteAll(db)
            try recipe.stepGraph.deleteAll(db)

            // Save recipe ingredients
            for index in ingredients.indices {
                ingredients[index].recipeId = recipe.id
                try ingredients[index].save(db)
            }

            var stepGraphRecord = RecipeStepGraphRecord(recipeId: recipe.id)
            try stepGraphRecord.save(db)

            for node in stepGraph.nodes {
                let step = node.label
                var stepRecord = RecipeStepRecord(graphId: stepGraphRecord.id, content: step.content)
                try stepRecord.save(db)
                step.id = stepRecord.id
            }

            for edge in stepGraph.edges {
                let sourceId = edge.source.label.id
                let destinationId = edge.destination.label.id
                var edgeRecord = RecipeStepEdgeRecord(graphId: stepGraphRecord.id,
                                                      sourceId: sourceId,
                                                      destinationId: destinationId)
                try edgeRecord.save(db)
            }
        }
    }

    func saveRecipeCategory(_ recipeCategory: inout RecipeCategoryRecord) throws {
        try dbWriter.write { db in
            try recipeCategory.save(db)
        }
    }

    func saveIngredient(_ ingredient: inout IngredientRecord) throws {
        var batches: [IngredientBatchRecord] = []

        try saveIngredient(&ingredient, batches: &batches)
    }

    func saveIngredient(_ ingredient: inout IngredientRecord, batches: inout [IngredientBatchRecord]) throws {
        try dbWriter.write { db in
            guard batches.allSatisfy({ $0.quantity.type == ingredient.quantityType }) else {
                throw DatabaseError(message: "Ingredient and ingredient batches do not have the same quantity type.")
            }

            try ingredient.save(db)

            guard batches.compactMap({ $0.ingredientId }).allSatisfy({ $0 == ingredient.id }) else {
                throw DatabaseError(message: "Ingredient batches belong to the wrong ingredient.")
            }

            // Delete all batches that are not in the array
            try ingredient.batches
                .filter(!batches.compactMap { $0.id }.contains(IngredientBatchRecord.Columns.id))
                .deleteAll(db)

            // Save ingredient batches
            for index in batches.indices {
                batches[index].ingredientId = ingredient.id
                try batches[index].save(db)
            }
        }
    }

    func saveIngredientCategory(_ ingredientCategory: inout IngredientCategoryRecord) throws {
        try dbWriter.write { db in
            try ingredientCategory.save(db)
        }
    }
}

// MARK: - Database Access: Delete

extension AppDatabase {
    func deleteRecipes(ids: [Int64]) throws {
        try dbWriter.write { db in
            _ = try RecipeRecord.deleteAll(db, keys: ids)
        }
    }

    func deleteAllRecipes() throws {
        try dbWriter.write { db in
            _ = try RecipeRecord.deleteAll(db)
        }
    }

    func deleteRecipeCategories(ids: [Int64]) throws {
        try dbWriter.write { db in
            _ = try RecipeCategoryRecord.deleteAll(db, keys: ids)
        }
    }

    func deleteAllRecipeCategories() throws {
        try dbWriter.write { db in
            _ = try RecipeCategoryRecord.deleteAll(db)
        }
    }

    func deleteIngredients(ids: [Int64]) throws {
        try dbWriter.write { db in
            _ = try IngredientRecord.deleteAll(db, keys: ids)
        }
    }

    func deleteAllIngredients() throws {
        try dbWriter.write { db in
            _ = try IngredientRecord.deleteAll(db)
        }
    }

    func deleteIngredientCategories(ids: [Int64]) throws {
        try dbWriter.write { db in
            _ = try IngredientCategoryRecord.deleteAll(db, keys: ids)
        }
    }

    func deleteAllIngredientCategories() throws {
        try dbWriter.write { db in
            _ = try IngredientCategoryRecord.deleteAll(db)
        }
    }
}

// MARK: - Database Access: Read

extension AppDatabase {
    func fetchRecipe(id: Int64) throws -> Recipe? {
        try dbWriter.read { db in
            let request = RecipeRecord
                .filter(key: id)
                .including(all: RecipeRecord.ingredients)
                .including(required: RecipeRecord.stepGraph
                    .including(all: RecipeStepGraphRecord.steps)
                    .including(all: RecipeStepGraphRecord.edges))

            return try Recipe.fetchOne(db, request)
        }
    }

    func fetchRecipe(onlineId: String) throws -> Recipe? {
        try dbWriter.read { db in
            let request = RecipeRecord
                .filter(RecipeRecord.Columns.onlineId == onlineId)
                .including(all: RecipeRecord.ingredients)
                .including(required: RecipeRecord.stepGraph
                    .including(all: RecipeStepGraphRecord.steps)
                    .including(all: RecipeStepGraphRecord.edges))

            return try Recipe.fetchOne(db, request)
        }
    }

    // TODO: Remove
    func fetchRecipeCategory(id: Int64) throws -> RecipeCategoryRecord? {
        try dbWriter.read { db in
            try RecipeCategoryRecord.fetchOne(db, key: id)
        }
    }

    // TODO: Remove
    func fetchRecipeCategory(name: String) throws -> RecipeCategoryRecord? {
        try dbWriter.read { db in
            try RecipeCategoryRecord.filter(RecipeCategoryRecord.Columns.name == name).fetchOne(db)
        }
    }

    func fetchIngredient(id: Int64) throws -> Ingredient? {
        try dbWriter.read { db in
            let request = IngredientRecord
                .filter(key: id)
                .including(all: IngredientRecord.batches)

            return try Ingredient.fetchOne(db, request)
        }
    }
}

// MARK: - Database Access: Publishers

extension AppDatabase {
    func recipePublisher(id: Int64) -> AnyPublisher<Recipe?, Error> {
        ValueObservation
            .tracking({ db in
                let request = RecipeRecord
                    .filter(key: id)
                    .including(optional: RecipeRecord.category)
                    .including(all: RecipeRecord.ingredients)
                    .including(required: RecipeRecord.stepGraph
                        .including(all: RecipeStepGraphRecord.steps)
                        .including(all: RecipeStepGraphRecord.edges))

                return try Recipe.fetchOne(db, request)
            })
            .publisher(in: dbWriter, scheduling: .immediate)
            .eraseToAnyPublisher()
    }

    func recipesPublisher(query: String = "",
                          categoryIds: [Int64?] = [nil],
                          ingredients: [String] = []) -> AnyPublisher<[RecipeRecord], Error> {
        ValueObservation
            .tracking(RecipeRecord.all()
                        .filteredByCategory(ids: categoryIds)
                        .filteredByName(query)
                        .filteredByIngredients(ingredients)
                        .orderedByName()
                        .fetchAll)
            .publisher(in: dbWriter, scheduling: .immediate)
            .eraseToAnyPublisher()
    }

    func recipeCategoriesPublisher() -> AnyPublisher<[RecipeCategoryRecord], Error> {
        ValueObservation
            .tracking(RecipeCategoryRecord.all().orderedByName().fetchAll)
            .publisher(in: dbWriter, scheduling: .immediate)
            .eraseToAnyPublisher()
    }

    func recipeIngredientsPublisher(categoryIds: [Int64?] = []) -> AnyPublisher<[RecipeIngredientRecord], Error> {
        ValueObservation
            .tracking(RecipeIngredientRecord.all().filteredByCategory(ids: categoryIds).fetchAll)
            .publisher(in: dbWriter, scheduling: .immediate)
            .eraseToAnyPublisher()
    }

    func ingredientPublisher(id: Int64) -> AnyPublisher<Ingredient?, Error> {
        ValueObservation
            .tracking({ db in
                let request = IngredientRecord
                    .filter(key: id)
                    .including(optional: IngredientRecord.category)
                    .including(all: IngredientRecord.batches)

                return try Ingredient.fetchOne(db, request)
            })
            .publisher(in: dbWriter, scheduling: .immediate)
            .eraseToAnyPublisher()
    }

    func ingredientsPublisher() -> AnyPublisher<[Ingredient], Error> {
        ValueObservation
            .tracking({ db in
                let request = IngredientRecord.all()
                    .orderedByName()
                    .including(all: IngredientRecord.batches)

                return try Ingredient.fetchAll(db, request)
            })
            .publisher(in: dbWriter, scheduling: .immediate)
            .eraseToAnyPublisher()
    }

    func ingredientsPublisher(query: String = "",
                              categoryIds: [Int64?] = [nil]) -> AnyPublisher<[Ingredient], Error> {
        ValueObservation
            .tracking({ db in
                let request = IngredientRecord.all()
                    .filteredByCategory(ids: categoryIds)
                    .filteredByName(query)
                    .orderedByName()
                    .including(all: IngredientRecord.batches)

                return try Ingredient.fetchAll(db, request)
            })
            .publisher(in: dbWriter, scheduling: .immediate)
            .eraseToAnyPublisher()
    }

    func ingredientsPublisher(expiresAfter: Date,
                              expiresBefore: Date,
                              query: String = "",
                              categoryIds: [Int64?] = [nil]) -> AnyPublisher<[Ingredient], Error> {
        ValueObservation
            .tracking({ db in
                let request = IngredientRecord.all()
                    .filteredByCategory(ids: categoryIds)
                    .filteredByName(query)
                    .filteredByExpiryDate(after: expiresAfter, before: expiresBefore)
                    .orderedByName()
                    .including(all: IngredientRecord.batches)

                return try Ingredient.fetchAll(db, request)
            })
            .publisher(in: dbWriter, scheduling: .immediate)
            .eraseToAnyPublisher()
    }

    func ingredientCategoriesPublisher() -> AnyPublisher<[IngredientCategoryRecord], Error> {
        ValueObservation
            .tracking(IngredientCategoryRecord.all().orderedByName().fetchAll)
            .publisher(in: dbWriter, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
}
