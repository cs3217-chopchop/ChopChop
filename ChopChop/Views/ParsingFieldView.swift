//
//  ParsingFieldView.swift
//  ChopChop
//
//  Created by Cao Wenjie on 18/3/21.
//

import SwiftUI

struct ParsingFieldView: View {

    @ObservedObject var viewModel: ParsingRecipeViewModel

    var body: some View {
        Form {
            Section(header: Text("Instructions")) {
                TextEditor(text: $viewModel.instructionString)
                    .disableAutocorrection(true)
            }
            Section(header: Text("Ingredients")) {
                TextEditor(text: $viewModel.ingredientString)
                    .disableAutocorrection(true)
            }
            Button(
                action: {
                    viewModel.parseData()
                },
                label: {
                    Text("Parse data")
                }
            )
        }
    }
}

struct ParsingFieldView_Previews: PreviewProvider {
    static var previews: some View {
        ParsingFieldView(viewModel: ParsingRecipeViewModel())
    }
}
