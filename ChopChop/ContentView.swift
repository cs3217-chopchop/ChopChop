//
//  ContentView.swift
//  ChopChop
//
//  Created by Chrystal on 9/3/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        RecipeFormView(viewModel: RecipeFormViewModel())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
