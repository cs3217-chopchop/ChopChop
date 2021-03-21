//
//  RecipeIngredientRow.swift
//  ChopChop
//
//  Created by Cao Wenjie on 20/3/21.
//
import SwiftUI

class RecipeIngredientRowViewModel: ObservableObject {
    @Published var amount: String = "" {
        didSet {
            ensureValidAmount()
        }
    }
    @Published var unit: String = ""
    @Published var ingredientName: String = ""

    static var unitList = ["gram", "kilogram", "tablespoon", "milliliter", "teaspoon", "liter", "count"]

    init(amount: String, unit: String, ingredientName: String) {
        self.amount = amount
        self.unit = unit
        self.ingredientName = ingredientName
    }

    init() {}

    func ensureValidAmount() {
        let filtered = amount.filter { "0123456789.".contains($0) }
        if filtered != amount {
            amount = filtered
        }
    }
}
