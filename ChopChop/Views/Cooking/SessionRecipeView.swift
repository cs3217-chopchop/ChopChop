import SwiftUI

struct SessionRecipeView: View {
    @ObservedObject var viewModel: SessionRecipeViewModel

    var body: some View {
        ZStack(alignment: .trailing) {
            SessionGraphView(viewModel: SessionGraphViewModel(graph: viewModel.recipe.stepGraph))

            if viewModel.showDetailsPanel {
                VStack(spacing: 24) {
                    ingredientsPanel
                    timersPanel
                }
                .frame(width: 250)
                .padding()
                .transition(AnyTransition.move(edge: .trailing))
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
        if !viewModel.recipe.recipe.ingredients.isEmpty {
            VStack {
                Text("Ingredients")
                    .font(.headline)
                ScrollView {
                    ForEach(viewModel.recipe.recipe.ingredients, id: \.name) { ingredient in
                        Text(ingredient.description)
                    }
                }
            }
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(panelBackground)
        }
    }

    @ViewBuilder
    var timersPanel: some View {
        if viewModel.recipe.stepGraph.hasTimers {
            VStack {
                Text("Timers")
                    .font(.headline)
                ScrollView {
                    ForEach(viewModel.recipe.stepGraph.topologicallySortedNodes) { node in
                        TimerNodeView(viewModel: TimerNodeViewModel(graph: viewModel.recipe.stepGraph,
                                                                    node: node))
                    }
                }
            }
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity)
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
}

struct SessionRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        if let recipe = try? Recipe(name: "Sample recipe") {
            SessionRecipeView(viewModel: SessionRecipeViewModel(recipe: recipe))
        }
    }
}
