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
        migrator.registerMigration("CreateRecipe") { db in
            try db.create(table: "recipe") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text)
                    .notNull()
                    .unique()
                    .check { $0 != "" }
                    .collate(.localizedStandardCompare)
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

        migrator.registerMigration("CreateRecipeStep") { db in
            try db.create(table: "recipeStep") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("recipeId", .integer)
                    .notNull()
                    .indexed()
                    .references("recipe", onDelete: .cascade)
                t.column("index", .integer)
                    .notNull()
                t.column("content", .text)
                    .notNull()
                    .check { $0 != "" }
                t.uniqueKey(["recipeId", "index"])
            }
        }

        migrator.registerMigration("CreateIngredient") { db in
            try db.create(table: "ingredient") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text)
                    .notNull()
                    .unique()
                    .check { $0 != "" }
                    .collate(.localizedStandardCompare)
            }
        }

        migrator.registerMigration("CreateIngredientSet") { db in
            try db.create(table: "ingredientSet") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("ingredientId", .integer)
                    .notNull()
                    .indexed()
                    .references("ingredient", onDelete: .cascade)
                // TODO: Check time is 0000
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

extension AppDatabase {
    func saveRecipe(_ recipe: Recipe) throws {
        var recipeRecord = RecipeRecord(id: recipe.id, name: recipe.name)
        var ingredientRecords = recipe.ingredients.map { name, quantity in
            RecipeIngredientRecord(recipeId: recipe.id, name: name, quantity: quantity)
        }
        var stepRecords = recipe.steps.enumerated().map { index, content in
            RecipeStepRecord(recipeId: recipe.id, index: index + 1, content: content)
        }

        try saveRecipe(&recipeRecord, ingredients: &ingredientRecords, steps: &stepRecords)
    }

    func saveRecipe(_ recipe: inout RecipeRecord,
                    ingredients: inout [RecipeIngredientRecord],
                    steps: inout [RecipeStepRecord]) throws {
        try dbWriter.write { db in
            try recipe.save(db)

            let recipeIds = ingredients.compactMap { $0.recipeId } + steps.compactMap { $0.recipeId }

            guard recipeIds.allSatisfy({ $0 == recipe.id }) else {
                throw DatabaseError(message: "Recipe ingredients and steps belong to the wrong recipe.")
            }

            guard steps.map({ $0.index }).allSatisfy({ (1...steps.count).contains($0) }) else {
                throw DatabaseError(message: "Recipe steps do not have consecutive indexes.")
            }

            // Delete all ingredients and steps that are not in the arrays
            try recipe.ingredients
                .filter(!ingredients.compactMap { $0.id }.contains(RecipeIngredientRecord.Columns.id))
                .deleteAll(db)
            try recipe.steps
                .filter(!steps.compactMap { $0.id }.contains(RecipeStepRecord.Columns.id))
                .deleteAll(db)

            // Save recipe ingredients and steps
            for index in ingredients.indices {
                ingredients[index].recipeId = recipe.id
                try ingredients[index].save(db)
            }

            for index in steps.indices {
                steps[index].recipeId = recipe.id
                try steps[index].save(db)
            }
        }
    }

    func saveIngredient(_ ingredient: Ingredient) throws {
        var ingredientRecord = IngredientRecord(id: ingredient.id, name: ingredient.name)
        var setRecords = ingredient.sets.map { expiryDate, quantity in
            IngredientSetRecord(ingredientId: ingredient.id, expiryDate: expiryDate, quantity: quantity)
        }

        try saveIngredient(&ingredientRecord, sets: &setRecords)
    }

    func saveIngredient(_ ingredient: inout IngredientRecord, sets: inout [IngredientSetRecord]) throws {
        try dbWriter.write { db in
            try ingredient.save(db)

            guard sets.compactMap({ $0.ingredientId }).allSatisfy({ $0 == ingredient.id }) else {
                throw DatabaseError(message: "Ingredient sets belong to the wrong ingredient.")
            }

            // Delete all sets that are not in the array
            try ingredient.sets
                .filter(!sets.compactMap { $0.id }.contains(IngredientSetRecord.Columns.id))
                .deleteAll(db)

            // Save ingredient sets
            for index in sets.indices {
                sets[index].ingredientId = ingredient.id
                try sets[index].save(db)
            }
        }
    }

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
}

extension AppDatabase {
    func recipesOrderedByNamePublisher() -> AnyPublisher<[RecipeRecord], Error> {
        ValueObservation
            .tracking(RecipeRecord.all().orderedByName().fetchAll)
            .publisher(in: dbWriter, scheduling: .immediate)
            .eraseToAnyPublisher()
    }

    func ingredientsOrderedByNamePublisher() -> AnyPublisher<[IngredientRecord], Error> {
        ValueObservation
            .tracking(IngredientRecord.all().orderedByName().fetchAll)
            .publisher(in: dbWriter, scheduling: .immediate)
            .eraseToAnyPublisher()
    }

    func ingredientsOrderedByExpiryDatePublisher() -> AnyPublisher<[IngredientRecord], Error> {
        ValueObservation
            .tracking(IngredientRecord.all().orderedByExpiryDate().fetchAll)
            .publisher(in: dbWriter, scheduling: .immediate)
            .eraseToAnyPublisher()
    }

    func fetchRecipe(_ recipe: RecipeRecord) throws -> Recipe? {
        try dbWriter.read { db in
            let request = RecipeRecord
                .filter(key: recipe.id)
                .including(all: RecipeRecord.ingredients)
                .including(all: RecipeRecord.steps)

            return try Recipe.fetchOne(db, request)
        }
    }

    func fetchIngredient(_ ingredient: IngredientRecord) throws -> Ingredient? {
        try dbWriter.read { db in
            let request = IngredientRecord
                .filter(key: ingredient.id)
                .including(all: IngredientRecord.sets)

            return try Ingredient.fetchOne(db, request)
        }
    }
}
