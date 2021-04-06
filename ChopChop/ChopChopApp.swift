import SwiftUI

@main
struct ChopChopApp: App {
    @StateObject var settings = UserSettings()
    let graph: RecipeStepGraph = {
        let nodes = [
            try? RecipeStep(content: """
                In a large bowl, mix dry ingredients together until well-blended.
                """),
            try? RecipeStep(content: "Add milk and mix well until smooth."),
            try? RecipeStep(content: """
                Separate the egg, placing the whites in a medium bowl and the yolks in the batter. Mix well.
                """),
            try? RecipeStep(content: "Beat whites until stiff and then fold into batter gently."),
            try? RecipeStep(content: """
                Pour ladles of the mixture into a non-stick pan, one at a time.
                """),
            try? RecipeStep(content: """
                Cook until the edges are dry and bubbles appear on surface. Flip; cook until golden. Yields 12 to 14 \
                pancakes.
                """),
            try? RecipeStep(content: """
                ad fasd fas dfas dkfamsdo fiasmd oiamdov iamdfvoi dmfoiv dmsfovi mdsfoiv mdsofiv msdfoivmsdfovi \
                padofim sdpofimasp oifmdp jfmsdpfvjsdpfvoj msdfpvomsd fpvokmdscpoask dm[oismdc[asokdcma s[odkcm as[ckm \
                [odifm [asoidmfpdfms fdo ismdfpv odsifmvpsodi fmvsdokf vmdp sofmv pdosfivm sdofivm sdpfoivm sdfpo \
                psodfim vsdpfoiv mdspfokv mfpo imdsfpov imsdfpo imvsdfpoi msvpdofvm pdsofimv spdofimv spdfomv
                """),
            try? RecipeStep(content: "H"),
            try? RecipeStep(content: "Test")
        ].compactMap { $0 }.map { RecipeStepNode($0) }
        let edges = [
            Edge(source: nodes[0], destination: nodes[1]),
            Edge(source: nodes[1], destination: nodes[2]),
            Edge(source: nodes[1], destination: nodes[3]),
            Edge(source: nodes[2], destination: nodes[4]),
            Edge(source: nodes[3], destination: nodes[5]),
            Edge(source: nodes[4], destination: nodes[6]),
            Edge(source: nodes[5], destination: nodes[6]),
            Edge(source: nodes[6], destination: nodes[7]),
            Edge(source: nodes[3], destination: nodes[8]),
            Edge(source: nodes[8], destination: nodes[7])
        ].compactMap { $0 }

        return (try? RecipeStepGraph(nodes: nodes, edges: edges)) ?? RecipeStepGraph()
    }()
    var sessionGraph: SessionRecipeStepGraph? {
        SessionRecipeStepGraph(graph: graph)
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                MainView(viewModel: MainViewModel())
            }
            .environmentObject(settings)
        }
    }
}
