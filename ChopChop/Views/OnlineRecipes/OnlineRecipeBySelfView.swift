import SwiftUI

struct OnlineRecipeBySelfView: View {
    @StateObject var viewModel: OnlineRecipeBySelfViewModel

    var body: some View {
        VStack(spacing: 0) {
            OnlineRecipeView(viewModel: viewModel)

            Divider()
            Button(action: viewModel.onDelete) {
                Label("Unpublish", systemImage: "trash")
                    .foregroundColor(.red)
            }
            .padding()
        }
        .overlay(
            RoundedRectangle(cornerRadius: 40)
                .stroke(Color.primary, lineWidth: 4)
        )
        .padding([.vertical], 50)
        .padding([.horizontal], 100)
    }
}
