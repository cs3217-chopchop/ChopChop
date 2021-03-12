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
                    .collate(.localizedStandardCompare)
            }
        }
        
        migrator.registerMigration("CreateIngredientReference") { db in
            try db.create(table: "ingredientReference") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("recipeId", .integer)
                    .notNull()
                    .indexed()
                    .references("recipe", onDelete: .cascade)
                t.column("name", .text)
                    .notNull()
                t.column("quantity", .text)
                    .notNull()
            }
        }
        
        migrator.registerMigration("CreateStep") { db in
            try db.create(table: "step") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("recipeId", .integer)
                    .notNull()
                    .indexed()
                    .references("recipe", onDelete: .cascade)
                t.column("index", .integer)
                    .notNull()
                t.column("text", .text)
                    .notNull()
            }
        }
        
        migrator.registerMigration("CreateIngredient") { db in
            try db.create(table: "ingredient") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text)
                    .notNull()
                    .unique()
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
    func saveRecipe(_ recipe: inout Recipe, ingredients: inout [IngredientReference], steps: inout [Step]) throws {
        try dbWriter.write { db in
            try recipe.save(db)
            try recipe.ingredients.deleteAll(db)
            try recipe.steps.deleteAll(db)

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
            try ingredient.sets.deleteAll(db)

            for index in sets.indices {
                sets[index].ingredientId = ingredient.id
                try sets[index].save(db)
            }
        }
    }
    
    func createIngredients() throws {
        try dbWriter.write { db in
            var ingredient = Ingredient(name: "test")
            
            try ingredient.save(db)
            
            var ingredientSet1 = IngredientSet(ingredientId: ingredient.id, expiryDate: Date(timeIntervalSinceNow: 0), quantity: .mass(1 / 7))
            var ingredientSet2 = IngredientSet(ingredientId: ingredient.id, expiryDate: Date(timeIntervalSinceNow: 1), quantity: .count(2))
            
            try ingredientSet1.save(db)
            try ingredientSet2.save(db)
        }
        
        try dbWriter.read { db in
            let ingredient = try Ingredient.fetchOne(db, key: 1)
            print(ingredient?.name)
            try print(ingredient?.sets.fetchAll(db).map { "\($0.expiryDate) / \($0.quantity)" })
        }
    }
}
