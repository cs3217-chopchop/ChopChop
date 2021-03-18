//
//  RecipeDetailView.swift
//  ChopChop
//
//  Created by Seow Alex on 18/3/21.
//

import SwiftUI

struct RecipeDetailView: View {
    let name: String

    var body: some View {
        Text(name)
    }
}

struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeDetailView(name: "")
    }
}
