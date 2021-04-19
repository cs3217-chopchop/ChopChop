// swiftlint:disable:this file_name

import SwiftUI

/**
 Represents a checkbox component that can be toggled.
 
 Reference: https://swiftwithmajid.com/2020/03/04/customizing-toggle-in-swiftui/
 */
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                .resizable()
                .frame(width: 22, height: 22)
                .onTapGesture { configuration.isOn.toggle() }
            configuration.label
        }
    }
}
