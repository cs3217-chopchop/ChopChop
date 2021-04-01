//
//  OnlineIngredientDetails.swift
//  ChopChop
//
//  Created by Cao Wenjie on 1/4/21.
//

final class OnlineIngredientDetails {
    private(set) var name: String
    private(set) var quantity: Quantity

    init(name: String, quantity: Quantity) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw IngredientError.emptyName
        }

        self.name = trimmedName
        self.quantity = quantity
    }
}

//extension OnlineIngredientDetails: Codable {
//}
