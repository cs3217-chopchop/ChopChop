//
//  TestingView.swift
//  ChopChop
//
//  Created by Cao Wenjie on 1/4/21.
//

import SwiftUI
import Combine

struct TestingView: View {
    let cancellable = Set<AnyCancellable>()
    let recipeName = ""
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct TestingView_Previews: PreviewProvider {
    static var previews: some View {
        TestingView()
    }
}
