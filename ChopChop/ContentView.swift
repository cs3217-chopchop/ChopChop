//
//  ContentView.swift
//  ChopChop
//
//  Created by Chrystal on 9/3/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        // swiftlint:disable force_try
        IngredientDetailView(
            viewModel: IngredientViewModel(
                ingredient: try! Ingredient(
                    name: "Apple",
                    type: .count,
                    batches: [
                        IngredientBatch(
                            quantity: try! Quantity(.count, value: 3),
                            expiryDate: Date()),
                        IngredientBatch(
                            quantity: try! Quantity(.count, value: 3)),
                        IngredientBatch(
                            quantity: try! Quantity(.count, value: 3),
                            expiryDate: Date().addingTimeInterval(100_000)),
                        IngredientBatch(
                            quantity: try! Quantity(.count, value: 3),
                            expiryDate: Date().addingTimeInterval(200_000))
                    ])))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
