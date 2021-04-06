import SwiftUI

struct NotFoundView: View {
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
