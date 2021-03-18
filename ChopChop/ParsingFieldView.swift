//
//  ParsingFieldView.swift
//  ChopChop
//
//  Created by Cao Wenjie on 18/3/21.
//

import SwiftUI

struct ParsingFieldView: View {
    @State private var ingredientString = ""
    @State private var instructionString = ""

//    private var steps = [String]()
//    private var ingredients = [String: Quantity]()

    var body: some View {
        Form {
            Section(header: Text("Instructions")) {
                TextEditor(text: $instructionString)
                    .disableAutocorrection(true)
            }
            Section(header: Text("Ingredients")) {
                TextEditor(text: $ingredientString)
                    .disableAutocorrection(true)
            }
            Button(
                action: {
                    parseData(instruction: instructionString, ingredient: ingredientString)
                },
                label: {
                    Text("Parse data")
                }
            )
        }
    }

    private func parseData(instruction: String, ingredient: String) {

        let ingredients = RecipeParser.parseIngredientString(ingredientString: ingredient)
//        let steps = split(whereSeparator: \.isNewline)
//            .map({ String($0) })
        let steps = RecipeParser.parseInstructions(instructions: instruction)
        print(ingredients)
        print(steps)
    }
}

struct ParsingFieldView_Previews: PreviewProvider {
    static var previews: some View {
        ParsingFieldView()
    }
}
