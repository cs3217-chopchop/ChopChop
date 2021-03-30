import SwiftUI

struct NodeView<Content: View>: View {
    let isSelected: Bool
    let content: Content

    init(isSelected: Bool = false, @ViewBuilder content: @escaping() -> Content) {
        self.isSelected = isSelected
        self.content = content()
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(Color.accentColor)
            .shadow(color: isSelected ? .accentColor : .clear, radius: 6)
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(UIColor.systemBackground).opacity(0.8))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(Color.accentColor, lineWidth: 1.5)
            )
            .overlay(content)
            .frame(width: isSelected ? Node.expandedSize.width : Node.normalSize.width,
                   height: isSelected ? Node.expandedSize.height : Node.normalSize.height)
            .zIndex(isSelected ? 1 : 0)
    }
}

 struct NodeView_Previews: PreviewProvider {
    static var previews: some View {
        NodeView {
            EmptyView()
        }
    }
 }
