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
                t.column("isImageUploaded", .boolean)
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

    // swiftlint:disable cyclomatic_complexity
    private func createPreloadedRecipes(_ db: Database) throws {
        guard let path = Bundle.main.path(forResource: "recipes", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe) else {
            return
        }

        let decoder = JSONDecoder()

        guard let recipes = try? decoder.decode([RecipeData].self, from: data) else {
            return
        }

        var categoryRecords = Set(recipes.map { $0.category }).map { RecipeCategoryRecord(name: $0) }

        for index in categoryRecords.indices {
            try categoryRecords[index].save(db)
        }

        var recipeRecords = recipes.map { recipe in
            RecipeRecord(recipeCategoryId: categoryRecords.first(where: { $0.name == recipe.category })?.id,
                         name: recipe.name,
                         servings: Double(Int.random(in: 1...5)),
                         difficulty: Difficulty.allCases.randomElement())
        }

        for index in recipeRecords.indices {
            try recipeRecords[index].save(db)
        }

        for recipe in recipeRecords {
            guard let id = recipe.id else {
                continue
            }

            try? ImageStore.save(image: UIImage(imageLiteralResourceName: recipe.name.lowercased()
                                                    .components(separatedBy: .whitespaces)
                                                    .joined(separator: "-")),
                                 name: String(id),
                                 inFolderNamed: StorageManager.recipeFolderName)
        }

        var ingredientRecords = recipes.flatMap { recipe in
            recipe.ingredients.map { ingredient in
                RecipeIngredientRecord(recipeId: recipeRecords.first(where: { $0.name == recipe.name })?.id,
                                       name: ingredient.name,
                                       quantity: ingredient.quantity)
            }
        }

        for index in ingredientRecords.indices {
            try ingredientRecords[index].save(db)
        }

        var graphRecords = recipeRecords.map { RecipeStepGraphRecord(recipeId: $0.id) }

        for index in graphRecords.indices {
            try graphRecords[index].save(db)
        }

        var stepRecords = recipes.flatMap { recipe in
            recipe.steps.map { content in
                RecipeStepRecord(graphId: recipeRecords.first(where: { $0.name == recipe.name })?.id,
                                 content: content)
            }
        }

        for index in stepRecords.indices {
            try stepRecords[index].save(db)

            let timers = RecipeStepParser.parseTimeStrings(step: stepRecords[index].content).map {
                TimeInterval(RecipeStepParser.parseDuration(timeString: $0))
            }

            for timer in timers {
                var timer = RecipeStepTimerRecord(stepId: stepRecords[index].id, duration: timer)

                try timer.save(db)
            }
        }

        var edgeRecords: [RecipeStepEdgeRecord] = stepRecords.indices.dropLast().compactMap { index in
            guard stepRecords[index].graphId == stepRecords[index + 1].graphId else {
                return nil
            }

            return RecipeStepEdgeRecord(graphId: stepRecords[index].graphId,
                                        sourceId: stepRecords[index].id,
                                        destinationId: stepRecords[index + 1].id)
        }

        for index in edgeRecords.indices {
            try edgeRecords[index].save(db)
        }
    }
    // swiftlint:enable cyclomatic_complexity
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
        guard let path = Bundle.main.path(forResource: "ingredients", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe) else {
            return
        }

        let decoder = JSONDecoder()

        guard let ingredients = try? decoder.decode([IngredientData].self, from: data) else {
            return
        }

        var categoryRecords = Set(ingredients.map { $0.category }).map { IngredientCategoryRecord(name: $0) }

        for index in categoryRecords.indices {
            try categoryRecords[index].save(db)
        }

        var ingredientRecords = ingredients.map { ingredient in
            IngredientRecord(ingredientCategoryId: categoryRecords.first(where: { $0.name == ingredient.category })?.id,
                             name: ingredient.name,
                             quantityType: ingredient.type)
        }

        for index in ingredientRecords.indices {
            try ingredientRecords[index].save(db)
        }

        for ingredient in ingredientRecords {
            guard let id = ingredient.id else {
                continue
            }

            try? ImageStore.save(image: UIImage(imageLiteralResourceName: ingredient.name.lowercased()
                                                    .components(separatedBy: .whitespaces)
                                                    .joined(separator: "-")),
                                 name: String(id),
                                 inFolderNamed: StorageManager.ingredientFolderName)
        }

        var batchRecords = ingredients.flatMap { ingredient in
            ingredient.quantities.indices.map { index in
                IngredientBatchRecord(ingredientId: ingredientRecords.first(where: { $0.name == ingredient.name })?.id,
                                      expiryDate: Date(timeIntervalSinceNow: 86_400 * TimeInterval(index + 1)),
                                      quantity: ingredient.quantities[index])
            }
        }

        for index in batchRecords.indices {
            try batchRecords[index].save(db)
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
                    throw DatabaseError(message:
                                            "Ingredient and ingredient batches do not have the same quantity type.")
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
