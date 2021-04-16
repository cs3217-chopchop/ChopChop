import SwiftUI

struct SessionRecipeView: View {
    @ObservedObject var viewModel: SessionRecipeViewModel

    var body: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .trailing) {
                SessionGraphView(viewModel: SessionGraphViewModel(graph: viewModel.sessionRecipe.stepGraph, proxy: proxy))

                if viewModel.showDetailsPanel {
                    VStack(spacing: 24) {
                        ingredientsPanel
                        timersPanel(proxy: proxy)
                    }
                    .frame(width: 250)
                    .padding()
                    .transition(.move(edge: .trailing))
                }
            }
        }
        .toolbar {
            Button(action: {
                withAnimation {
                    viewModel.showDetailsPanel.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "dial.min")
                }
            }
        }
    }

    @ViewBuilder
    var ingredientsPanel: some View {
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

    var panelBackground: some View {
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
    func timersPanel(proxy: ScrollViewProxy) -> some View {
        if viewModel.sessionRecipe.stepGraph.hasTimers {
            ScrollView {
                VStack {
                    ForEach(viewModel.sessionRecipe.stepGraph.topologicallySortedNodes) { node in
                        TimerNodeView(viewModel: TimerNodeViewModel(graph: viewModel.sessionRecipe.stepGraph,
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
