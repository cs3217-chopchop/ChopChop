import SwiftUI

/**
 Represents a view that displays the lack of an entity.
 */
struct NotFoundView: View {
    /// The name of the entity.
    let entityName: String

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Image(systemName: "text.badge.xmark")
                .font(.system(size: 60))
            Text("No \(entityName) Found")
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .foregroundColor(.secondary)
    }
}

struct NotFoundView_Previews: PreviewProvider {
    static var previews: some View {
        NotFoundView(entityName: "Recipes")
    }
}
