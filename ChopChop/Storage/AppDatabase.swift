// swiftlint:disable file_length function_body_length

import Combine
import Foundation
import GRDB
import UIKit

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
                t.column("parentOnlineRecipeId", .text)
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

        migrator.registerMigration("CreateRecipeStepTimer") { db in
            try db.create(table: "recipeStepTimer") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("stepId", .integer)
                    .notNull()
                    .indexed()
                    .references("recipeStep", onDelete: .cascade)
                t.column("duration", .double)
                    .notNull()
                    .check { $0 > 0 }
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
                    .check { QuantityType.allCases.map { $0.rawValue }.contains($0) }
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
        var categories = ["American", "Italian", "Japanese"].map { RecipeCategoryRecord(name: $0) }

        for index in categories.indices {
            try categories[index].save(db)
        }

        var recipes: [RecipeRecord] = [
            "American": ["Pancakes", "Scrambled Eggs", "Pizza"],
            "Italian": ["Carbonara"],
            "Japanese": ["Ramen", "Katsudon"]
        ].reduce(into: []) { recipes, entry in
            for name in entry.value {
                recipes.append(RecipeRecord(recipeCategoryId: categories.first(where: { $0.name == entry.key })?.id,
                                            name: name,
                                            servings: Double(Int.random(in: 1...5)),
                                            difficulty: Difficulty.allCases.randomElement()))
            }
        }

        for index in recipes.indices {
            try recipes[index].save(db)
        }

        for recipe in recipes {
            guard let id = recipe.id else {
                continue
            }

            try? ImageStore.save(image: UIImage(imageLiteralResourceName: recipe.name.lowercased()
                                                    .components(separatedBy: .whitespaces)
                                                    .joined(separator: "-")),
                                 name: String(id),
                                 inFolderNamed: StorageManager.recipeFolderName)
        }

        var ingredients: [RecipeIngredientRecord] = [
            "Pancakes": [
                ("flour", QuantityRecord.volume(0.5, unit: .cup)),
                ("baking powder", QuantityRecord.volume(1.5, unit: .teaspoon)),
                ("salt", QuantityRecord.volume(1, unit: .teaspoon)),
                ("milk", QuantityRecord.volume(1, unit: .cup)),
                ("sugar", QuantityRecord.volume(1, unit: .tablespoon))
            ],
            "Katsudon": [
                ("pork chops", QuantityRecord.count(2)),
                ("salt", QuantityRecord.volume(1, unit: .teaspoon)),
                ("pepper", QuantityRecord.volume(1, unit: .teaspoon)),
                ("eggs", QuantityRecord.count(5)),
                ("panko", QuantityRecord.volume(1, unit: .cup)),
                ("soup stock", QuantityRecord.volume(1.25, unit: .cup)),
                ("soy sauce", QuantityRecord.volume(0.3, unit: .cup)),
                ("mirin", QuantityRecord.volume(2, unit: .tablespoon)),
                ("onion", QuantityRecord.count(1)),
                ("rice", QuantityRecord.volume(4, unit: .cup))
            ]
        ].reduce(into: []) { ingredients, entry in
            for ingredient in entry.value {
                ingredients.append(RecipeIngredientRecord(recipeId: recipes.first(where: { $0.name == entry.key })?.id,
                                                          name: ingredient.0,
                                                          quantity: ingredient.1))
            }
        }

        for index in ingredients.indices {
            try ingredients[index].save(db)
        }

        var graphs = recipes.map { RecipeStepGraphRecord(recipeId: $0.id) }

        for index in graphs.indices {
            try graphs[index].save(db)
        }

        var steps: [RecipeStepRecord] = [
            "Pancakes": [
                "In a large bowl, mix dry ingredients together until well-blended.",
                "Add milk and mix well until smooth.",
                "Separate the egg, placing the whites in a medium bowl and the yolks in the batter. Mix well.",
                "Beat whites until stiff and then fold into batter gently.",
                "Pour ladles of the mixture into a non-stick pan, one at a time.",
                """
                Cook until the edges are dry and bubbles appear on surface. Flip; cook until golden. \
                Yields 12 to 14 pancakes.
                """
            ],
            "Katsudon": [
                "Gather the ingredients.",
                "Season the pounded pork chops with salt and pepper.",
                "Dust with a light, even coating of flour.",
                "In one shallow bowl, beat 1 of the eggs. Put the panko into another shallow bowl.",
                """
                Add a thin, even layer of oil to a cast-iron pan or skillet over medium heat. \
                The oil is ready when you drop a panko breadcrumb into it and it sizzles.
                """,
                "Dip the flour-dusted pork into the egg to coat both sides.",
                "Transfer the pork to the panko and press it evenly into the meat to get a good coating.",
                """
                Carefully lay the pork chops in the hot oil and cook for 5 to 6 minutes on one side, \
                until golden brown.
                """,
                """
                Flip and cook the other side for another 5 to 6 minutes, or until browned, crispy, \
                and cooked through.
                """,
                "Drain on a plate lined with a paper towel.",
                "Slice your tonkatsu into pieces.",
                "Put the dashi soup stock in a pan and heat on medium heat.",
                "Add the soy sauce, mirin, and sugar to the soup and bring to a boil. Remove from the heat.",
                """
                To cook 1 serving of katsudon, put 1/4 of the soup and 1/4 of the sliced onion in a small skillet. \
                Simmer for a few minutes on medium heat.
                """,
                """
                Add 1 serving of tonkatsu pieces (half of 1 pork cutlet) to the pan and simmer on low heat for \
                2 or 3 minutes.
                """,
                """
                Beat another one of the eggs in a bowl. Bring the soup to a boil and pour the egg over \
                the tonkatsu and onion.
                """,
                """
                Turn the heat down to low and cover with a lid. Cook until the egg has set and remove it from the heat.
                The egg should be cooked through.
                """,
                """
                Serve by placing 1 serving of steamed rice in a large rice bowl. \
                Top with the simmered tonkatsu on top of the rice. Repeat to make 3 more servings.
                """
            ]
        ].reduce(into: []) { steps, entry in
            for step in entry.value {
                steps.append(RecipeStepRecord(graphId: recipes.first(where: { $0.name == entry.key })?.id,
                                              content: step))
            }
        }

        for index in steps.indices {
            try steps[index].save(db)

            let timers = RecipeStepParser.parseTimeStrings(step: steps[index].content).map {
                TimeInterval(RecipeStepParser.parseDuration(timeString: $0))
            }

            for timer in timers {
                var timer = RecipeStepTimerRecord(stepId: steps[index].id, duration: timer)

                try timer.save(db)
            }
        }

        var edges: [RecipeStepEdgeRecord] = steps.indices.dropLast().compactMap { index in
            guard steps[index].graphId == steps[index + 1].graphId else {
                return nil
            }

            return RecipeStepEdgeRecord(graphId: steps[index].graphId,
                                        sourceId: steps[index].id,
                                        destinationId: steps[index + 1].id)
        }

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
        // swiftlint:disable closure_body_length
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

            var nodeIds: [UUID: Int64?] = [:]

            for node in stepGraph.nodes {
                let step = node.label
                var stepRecord = RecipeStepRecord(graphId: stepGraphRecord.id, content: step.content)
                try stepRecord.save(db)

                nodeIds[node.id] = stepRecord.id

                for timer in step.timers {
                    var timerRecord = RecipeStepTimerRecord(stepId: stepRecord.id, duration: timer)
                    try timerRecord.save(db)
                }
            }

            for edge in stepGraph.edges {
                let sourceId = nodeIds[edge.source.id, default: nil]
                let destinationId = nodeIds[edge.destination.id, default: nil]
                var edgeRecord = RecipeStepEdgeRecord(graphId: stepGraphRecord.id,
                                                      sourceId: sourceId,
                                                      destinationId: destinationId)
                try edgeRecord.save(db)
            }
        }
        // swiftlint:enable closure_body_length
    }

    func saveRecipeCategory(_ recipeCategory: inout RecipeCategoryRecord) throws {
        try dbWriter.write { db in
            try recipeCategory.save(db)
        }
    }

    // For saving multiple ingredients in one transaction
    func saveIngredients(_ ingredients: inout [(IngredientRecord, [IngredientBatchRecord])]) throws {
        try dbWriter.write { db in
            for index in ingredients.indices {
                guard ingredients[index].1.allSatisfy({ $0.quantity.type == ingredients[index].0.quantityType }) else {
                    throw DatabaseError(message: "Ingredient and ingredient batches do not have the same quantity type.")
                }

                // Save ingredient
                try ingredients[index].0.save(db)

                guard ingredients[index].1.compactMap({ $0.ingredientId })
                        .allSatisfy({ $0 == ingredients[index].0.id }) else {
                    throw DatabaseError(message: "Ingredient batches belong to the wrong ingredient.")
                }

                // Delete all batches that are not in the array
                try ingredients[index].0.batches
                    .filter(!ingredients[index].1.compactMap { $0.id }.contains(IngredientBatchRecord.Columns.id))
                    .deleteAll(db)

                // Save ingredient batches
                for batchIndex in ingredients[index].1.indices {
                    ingredients[index].1[batchIndex].ingredientId = ingredients[index].0.id
                    try ingredients[index].1[batchIndex].save(db)
                }
            }
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
            _ = try RecipeRecord.deleteAll(db, ids: ids)
        }
    }

    func deleteAllRecipes() throws {
        try dbWriter.write { db in
            _ = try RecipeRecord.deleteAll(db)
        }
    }

    func deleteRecipeCategories(ids: [Int64]) throws {
        try dbWriter.write { db in
            _ = try RecipeCategoryRecord.deleteAll(db, ids: ids)
        }
    }

    func deleteAllRecipeCategories() throws {
        try dbWriter.write { db in
            _ = try RecipeCategoryRecord.deleteAll(db)
        }
    }

    func deleteIngredients(ids: [Int64]) throws {
        try dbWriter.write { db in
            _ = try IngredientRecord.deleteAll(db, ids: ids)
        }
    }

    func deleteAllIngredients() throws {
        try dbWriter.write { db in
            _ = try IngredientRecord.deleteAll(db)
        }
    }

    func deleteIngredientCategories(ids: [Int64]) throws {
        try dbWriter.write { db in
            _ = try IngredientCategoryRecord.deleteAll(db, ids: ids)
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
                .filter(id: id)
                .including(optional: RecipeRecord.category)
                .including(all: RecipeRecord.ingredients)
                .including(required: RecipeRecord.stepGraph
                    .including(all: RecipeStepGraphRecord.steps
                                .including(all: RecipeStepRecord.timers))
                    .including(all: RecipeStepGraphRecord.edges))

            return try Recipe.fetchOne(db, request)
        }
    }

    func fetchRecipe(onlineId: String) throws -> Recipe? {
        try dbWriter.read { db in
            let request = RecipeRecord
                .filter(RecipeRecord.Columns.onlineId == onlineId)
                .including(optional: RecipeRecord.category)
                .including(all: RecipeRecord.ingredients)
                .including(required: RecipeRecord.stepGraph
                    .including(all: RecipeStepGraphRecord.steps
                                .including(all: RecipeStepRecord.timers))
                    .including(all: RecipeStepGraphRecord.edges))

            return try Recipe.fetchOne(db, request)
        }
    }

    func fetchDownloadedRecipes(parentOnlineRecipeId: String) throws -> [Recipe] {
        try dbWriter.read { db in
            let request = RecipeRecord
                .filter(RecipeRecord.Columns.parentOnlineRecipeId == parentOnlineRecipeId)
                .including(all: RecipeRecord.ingredients)
                .including(required: RecipeRecord.stepGraph
                    .including(all: RecipeStepGraphRecord.steps)
                    .including(all: RecipeStepGraphRecord.edges))
            return try Recipe.fetchAll(db, request)
        }
    }

    func fetchRecipeCategory(name: String) throws -> RecipeCategory? {
        try dbWriter.read { db in
            let request = RecipeCategoryRecord
                .filter(RecipeCategoryRecord.Columns.name == name)

            return try RecipeCategory.fetchOne(db, request)
        }
    }

    func fetchIngredients() throws -> [Ingredient] {
        try dbWriter.read { db in
            let request = IngredientRecord
                .all()
                .including(all: IngredientRecord.batches)

            return try Ingredient.fetchAll(db, request)
        }
    }

    func fetchIngredient(id: Int64) throws -> Ingredient? {
        try dbWriter.read { db in
            let request = IngredientRecord
                .filter(id: id)
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
                    .filter(id: id)
                    .including(optional: RecipeRecord.category)
                    .including(all: RecipeRecord.ingredients)
                    .including(required: RecipeRecord.stepGraph
                        .including(all: RecipeStepGraphRecord.steps
                                    .including(all: RecipeStepRecord.timers))
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
                    .filter(id: id)
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
