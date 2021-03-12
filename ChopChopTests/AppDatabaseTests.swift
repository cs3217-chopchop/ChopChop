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

    func testExample() throws {
        try dbWriter.write { db in
            var ingredient = Ingredient(name: "test")

            try ingredient.save(db)

            var ingredientSet1 = IngredientSet(ingredientId: ingredient.id,
                                               expiryDate: Date(timeIntervalSinceNow: 0),
                                               quantity: .mass(1 / 7))
            var ingredientSet2 = IngredientSet(ingredientId: ingredient.id,
                                               expiryDate: Date(timeIntervalSinceNow: 1),
                                               quantity: .count(2))

            try ingredientSet1.save(db)
            try ingredientSet2.save(db)
        }

        try dbWriter.read { db in
            let ingredient = try Ingredient.fetchOne(db, key: 1)
            print(ingredient?.name ?? "")
            try print(ingredient?.sets.fetchAll(db).map { "\($0.expiryDate) / \($0.quantity)" } ?? "")
        }
    }
}
