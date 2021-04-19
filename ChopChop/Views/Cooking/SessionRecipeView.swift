import SwiftUI

/**
 Represents a view of a recipe being made.
 */
struct SessionRecipeView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: SessionRecipeViewModel

    var body: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .trailing) {
                SessionGraphView(
                    viewModel: SessionGraphViewModel(
                        graph: viewModel.sessionRecipe.stepGraph,
                        proxy: proxy))

                if viewModel.showDetailsPanel {
                    detailsPanel(proxy)
                }
            }
        }
        .toolbar {
            completeRecipeButton

            if !viewModel.sessionRecipe.recipe.ingredients.isEmpty || viewModel.sessionRecipe.stepGraph.hasTimers {
                togglePanelButton
            }
        }
        .sheet(
            isPresented: $viewModel.sheetIsPresented,
            onDismiss: {
                if viewModel.isComplete {
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                CompleteSessionRecipeView(
                    viewModel: CompleteSessionRecipeViewModel(recipe: viewModel.sessionRecipe.recipe),
                    isComplete: $viewModel.isComplete)
        }
    }

    // MARK: - Toolbar

    private var completeRecipeButton: some View {
        Button(action: {
            viewModel.sheetIsPresented = true
        }) {
            Image(systemName: "checkmark")
        }
    }

    private var togglePanelButton: some View {
        Button(action: {
            withAnimation {
                viewModel.showDetailsPanel.toggle()
            }
        }) {
            Image(systemName: "gauge")
        }
    }

    // MARK: - Details Panel

    private func detailsPanel(_ proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 24) {
            ingredientsPanel
            timersPanel(proxy: proxy)
        }
        .frame(width: 250)
        .padding()
        .transition(.move(edge: .trailing))
    }

    @ViewBuilder
    private var ingredientsPanel: some View {
        if !viewModel.sessionRecipe.recipe.ingredients.isEmpty {
            VStack {
                Text("Ingredients")
                    .font(.headline)
                ScrollView {
                    VStack {
                        ForEach(viewModel.sessionRecipe.recipe.ingredients, id: \.name) { ingredient in
                            Text(ingredient.description)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                }
            }
            .padding()
            .background(panelBackground)
        }
    }

    private var panelBackground: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(Color.accentColor)
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(UIColor.systemBackground).opacity(0.8))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(Color.accentColor, lineWidth: 1.5)
            )
    }

    @ViewBuilder
    private func timersPanel(proxy: ScrollViewProxy) -> some View {
        if viewModel.sessionRecipe.stepGraph.hasTimers {
            ScrollView {
                VStack {
                    ForEach(viewModel.sessionRecipe.stepGraph.topologicallySortedNodes) { node in
                        TimerNodeView(
                            viewModel: TimerNodeViewModel(
                                graph: viewModel.sessionRecipe.stepGraph,
                                node: node,
                                proxy: proxy))
                            .id(node)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            .padding()
            .background(panelBackground)
        }
    }
}

struct SessionRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        if let recipe = try? Recipe(name: "Sample recipe") {
            SessionRecipeView(viewModel: SessionRecipeViewModel(recipe: recipe))
        }
    }
}
