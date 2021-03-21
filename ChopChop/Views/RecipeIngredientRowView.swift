//
//  RecipeIngredientRowView.swift
//  ChopChop
//
//  Created by Cao Wenjie on 20/3/21.
//

import SwiftUI
import Combine

struct RecipeIngredientRowView: View {
    @ObservedObject var viewModel: RecipeIngredientRowViewModel

    var body: some View {
        HStack {
            quantity
            Picker("Unit", selection: $viewModel.unit) {
                ForEach(RecipeIngredientRowViewModel.unitList, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(MenuPickerStyle())
            Spacer()
            Text(viewModel.unit)
            TextField("Ingredient", text: $viewModel.ingredientName)
        }
    }

    var quantity: some View {
        TextField("Quantity", text: $viewModel.amount)
    }
}

struct RecipeIngredientRowView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeIngredientRowView(viewModel: RecipeIngredientRowViewModel())
    }
}
