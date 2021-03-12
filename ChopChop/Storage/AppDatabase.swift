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
                    // TODO: Unique on foreign key
                    .unique()
                    .check { $0 != "" }
                t.column("quantity", .text)
                    .notNull()
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
                    // TODO: Unique on foreign key
                    .unique()
                t.column("content", .text)
                    .notNull()
                    .check { $0 != "" }
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
                t.column("expiryDate", .date)
                    .notNull()
                    // TODO: Unique on foreign key
                    .unique()
                    // TODO: Check time is 0000
                t.column("quantity", .text)
                    .notNull()
            }
        }

        return migrator
    }

    init(_ dbWriter: DatabaseWriter) throws {
        self.dbWriter = dbWriter
        try migrator.migrate(dbWriter)
    }
}

extension AppDatabase {
    func saveRecipe(_ recipe: inout Recipe, ingredients: inout [RecipeIngredient], steps: inout [RecipeStep]) throws {
        try dbWriter.write { db in
            try recipe.save(db)

            let recipeIds = ingredients.compactMap { $0.recipeId } + steps.compactMap { $0.recipeId }

            guard recipeIds.allSatisfy({ $0 == recipe.id }) else {
                throw DatabaseError(message: "Recipe ingredients and steps belong to the wrong recipe")
            }

            // Delete all ingredients and steps that are not in the arrays
            try recipe.ingredients
                .filter(!ingredients.compactMap { $0.id }.contains(RecipeIngredient.Columns.id))
                .deleteAll(db)
            try recipe.steps
                .filter(!steps.compactMap { $0.id }.contains(RecipeStep.Columns.id))
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

    func saveIngredient(_ ingredient: inout Ingredient, sets: inout [IngredientSet]) throws {
        try dbWriter.write { db in
            try ingredient.save(db)

            guard sets.compactMap({ $0.ingredientId }).allSatisfy({ $0 == ingredient.id }) else {
                throw DatabaseError(message: "Ingredient sets belong to the wrong ingredient")
            }

            // Delete all sets that are not in the array
            try ingredient.sets
                .filter(!sets.compactMap { $0.id }.contains(IngredientSet.Columns.id))
                .deleteAll(db)

            // Save ingredient sets
            for index in sets.indices {
                sets[index].ingredientId = ingredient.id
                try sets[index].save(db)
            }
        }
    }
}
