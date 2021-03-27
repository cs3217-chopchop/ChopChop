import Combine
import CoreGraphics
import SwiftGraph

final class SurfaceViewModel: ObservableObject {
    @Published var graph: UnweightedGraph<Node>

    init() {
        let vertices = [
            Node(position: CGPoint(x: 500, y: -100), text: """
                In a large bowl, mix dry ingredients together until well-blended.
                """),
            Node(position: CGPoint(x: 500, y: 200), text: "Add milk and mix well until smooth."),
            Node(position: CGPoint(x: 400, y: 300), text: """
                Separate the egg, placing the whites in a medium bowl and the yolks in the batter. Mix well.
                """),
            Node(position: CGPoint(x: 600, y: 300), text: "Beat whites until stiff and then fold into batter gently."),
            Node(position: CGPoint(x: 400, y: 400), text: """
                Pour ladles of the mixture into a non-stick pan, one at a time.
                """),
            Node(position: CGPoint(x: 600, y: 400), text: """
                Cook until the edges are dry and bubbles appear on surface. Flip; cook until golden. Yields 12 to 14 \
                pancakes.
                """),
            Node(position: CGPoint(x: 300, y: 900), text: """
                ad fasd fas dfas dkfamsdo fiasmd oiamdov iamdfvoi dmfoiv dmsfovi mdsfoiv mdsofiv msdfoivmsdfovi \
                padofim sdpofimasp oifmdp jfmsdpfvjsdpfvoj msdfpvomsd fpvokmdscpoask dm[oismdc[asokdcma s[odkcm as[ckm \
                [odifm [asoidmfpdfms fdo ismdfpv odsifmvpsodi fmvsdokf vmdp sofmv pdosfivm sdofivm sdpfoivm sdfpo \
                psodfim vsdpfoiv mdspfokv mfpo imdsfpov imsdfpo imvsdfpoi msvpdofvm pdsofimv spdofimv spdfomv
                """),
            Node(position: CGPoint(x: 500, y: 800), text: "H")
        ]

        graph = UnweightedGraph(vertices: vertices)
        graph.addEdge(fromIndex: 0, toIndex: 1, directed: true)
        graph.addEdge(fromIndex: 1, toIndex: 2, directed: true)
        graph.addEdge(fromIndex: 1, toIndex: 3, directed: true)
        graph.addEdge(fromIndex: 2, toIndex: 4, directed: true)
        graph.addEdge(fromIndex: 3, toIndex: 5, directed: true)
        graph.addEdge(fromIndex: 4, toIndex: 6, directed: true)
        graph.addEdge(fromIndex: 5, toIndex: 6, directed: true)
        graph.addEdge(fromIndex: 6, toIndex: 7, directed: true)
    }
}
