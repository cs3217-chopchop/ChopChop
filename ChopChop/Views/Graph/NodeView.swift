import SwiftUI

struct NodeView<Content: View>: View {
    let isSelected: Bool
    let isFaded: Bool
    let content: Content

    init(isSelected: Bool = false, isFaded: Bool = false, @ViewBuilder content: @escaping() -> Content) {
        self.isSelected = isSelected
        self.isFaded = isFaded
        self.content = content()
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(Color.accentColor)
            .shadow(color: isSelected && !isFaded ? .accentColor : .clear, radius: 6)
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(UIColor.systemBackground).opacity(isFaded ? 0.9 : 0.8))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(Color.accentColor, lineWidth: 1.5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(isFaded
                                        ? Color(UIColor.systemBackground).opacity(0.6)
                                        : Color.clear, lineWidth: 1.5)
                    )
            )
            .overlay(content)
            .frame(width: isSelected ? RecipeStepNode.expandedSize.width : RecipeStepNode.normalSize.width,
                   height: isSelected ? RecipeStepNode.expandedSize.height : RecipeStepNode.normalSize.height)
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
