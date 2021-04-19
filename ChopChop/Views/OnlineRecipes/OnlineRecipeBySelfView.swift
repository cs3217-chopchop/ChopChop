import SwiftUI

/**
 Represents a view of a recipe published online by the current user.
 */
struct OnlineRecipeBySelfView: View {
    let viewModel: OnlineRecipeBySelfViewModel

    var body: some View {
        VStack(spacing: 0) {
            OnlineRecipeView(viewModel: viewModel)
            Divider()
            unpublishButton
        }
        .overlay(
            RoundedRectangle(cornerRadius: 40)
                .stroke(Color.primary, lineWidth: 4)
        )
        .padding([.vertical], 50)
        .padding([.horizontal], 100)
    }

    private var unpublishButton: some View {
        Button(action: viewModel.onDelete) {
            Label("Unpublish", systemImage: "trash")
                .foregroundColor(.red)
        }
        .padding()
    }
}
