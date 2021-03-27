import XCTest

@testable import ChopChop

class SessionRecipeStepGraphTests: XCTestCase {
    func testConstruct() throws {
        let recipeSteps = [
            try RecipeStep(content: """
                Boil a large, salted pot of water for the pasta and cook it al dente according to package directions.
            """),
            try RecipeStep(content: """
                Meanwhile, add the butter and oil to a skillet over medium-high heat.
            """),
            try RecipeStep(content: """
                Add the mushrooms and garlic to the pan and sauté for about 5 minutes, stirring often,
                until the mushrooms release most of their water and it's cooked off.
            """),
            try RecipeStep(content: """
                In the meantime, mix the wine, Italian seasoning, lemon juice, flour, and Dijon mustard together.
            """),
            try RecipeStep(content: """
                Once done, take the mushrooms out of the pan and set aside.
            """),
            try RecipeStep(content: """
                Add the mix to the pan. Stir until it becomes a smooth paste.
            """),
            try RecipeStep(content: """
                Stir in the cream and let it simmer for a couple of minutes.
            """),
            try RecipeStep(content: """
                Add the mushrooms back into the pan.
                Reduce the heat and cook for a few more minutes until the sauce has thickened up a bit.
                Season sauce with salt & pepper as needed.
            """),
            try RecipeStep(content: """
                Drain the pasta and toss it with the sauce along with the parsley and parmesan if using.
            """)
        ]
        let recipeStepNodes = recipeSteps.map { RecipeStepNode($0) }

        let recipeStepEdges = [
            Edge<RecipeStepNode>(source: recipeStepNodes[0], destination: recipeStepNodes[1]),
            Edge<RecipeStepNode>(source: recipeStepNodes[0], destination: recipeStepNodes[8]),
            Edge<RecipeStepNode>(source: recipeStepNodes[1], destination: recipeStepNodes[2]),
            Edge<RecipeStepNode>(source: recipeStepNodes[2], destination: recipeStepNodes[3]),
            Edge<RecipeStepNode>(source: recipeStepNodes[2], destination: recipeStepNodes[4]),
            Edge<RecipeStepNode>(source: recipeStepNodes[3], destination: recipeStepNodes[5]),
            Edge<RecipeStepNode>(source: recipeStepNodes[4], destination: recipeStepNodes[5]),
            Edge<RecipeStepNode>(source: recipeStepNodes[5], destination: recipeStepNodes[6]),
            Edge<RecipeStepNode>(source: recipeStepNodes[6], destination: recipeStepNodes[7]),
            Edge<RecipeStepNode>(source: recipeStepNodes[7], destination: recipeStepNodes[8])
        ].compactMap { $0 }

        let recipeStepGraph = RecipeStepGraph()
        for edge in recipeStepEdges {
            try recipeStepGraph.addEdge(edge)
        }

        guard let graph = SessionRecipeStepGraph(graph: recipeStepGraph) else {
            XCTFail("Graph initialisation failed")
            return
        }

        for node in graph.nodes {
            XCTAssertTrue(recipeSteps.contains(node.label))
        }

        for edge in graph.edges {
            XCTAssertTrue(recipeStepEdges.contains(where: {
                $0.source.label == edge.source.label && $0.destination.label == edge.destination.label
            }))
        }
    }

    func testResetSteps_success() throws {
        let recipeSteps = [
            try RecipeStep(content: """
                Boil a large, salted pot of water for the pasta and cook it al dente according to package directions.
            """),
            try RecipeStep(content: """
                Meanwhile, add the butter and oil to a skillet over medium-high heat.
            """),
            try RecipeStep(content: """
                Add the mushrooms and garlic to the pan and sauté for about 5 minutes, stirring often,
                until the mushrooms release most of their water and it's cooked off.
            """),
            try RecipeStep(content: """
                In the meantime, mix the wine, Italian seasoning, lemon juice, flour, and Dijon mustard together.
            """),
            try RecipeStep(content: """
                Once done, take the mushrooms out of the pan and set aside.
            """),
            try RecipeStep(content: """
                Add the mix to the pan. Stir until it becomes a smooth paste.
            """),
            try RecipeStep(content: """
                Stir in the cream and let it simmer for a couple of minutes.
            """),
            try RecipeStep(content: """
                Add the mushrooms back into the pan.
                Reduce the heat and cook for a few more minutes until the sauce has thickened up a bit.
                Season sauce with salt & pepper as needed.
            """),
            try RecipeStep(content: """
                Drain the pasta and toss it with the sauce along with the parsley and parmesan if using.
            """)
        ]
        let recipeStepNodes = recipeSteps.map { RecipeStepNode($0) }

        let recipeStepEdges = [
            Edge<RecipeStepNode>(source: recipeStepNodes[0], destination: recipeStepNodes[1]),
            Edge<RecipeStepNode>(source: recipeStepNodes[0], destination: recipeStepNodes[8]),
            Edge<RecipeStepNode>(source: recipeStepNodes[1], destination: recipeStepNodes[2]),
            Edge<RecipeStepNode>(source: recipeStepNodes[2], destination: recipeStepNodes[3]),
            Edge<RecipeStepNode>(source: recipeStepNodes[2], destination: recipeStepNodes[4]),
            Edge<RecipeStepNode>(source: recipeStepNodes[3], destination: recipeStepNodes[5]),
            Edge<RecipeStepNode>(source: recipeStepNodes[4], destination: recipeStepNodes[5]),
            Edge<RecipeStepNode>(source: recipeStepNodes[5], destination: recipeStepNodes[6]),
            Edge<RecipeStepNode>(source: recipeStepNodes[6], destination: recipeStepNodes[7]),
            Edge<RecipeStepNode>(source: recipeStepNodes[7], destination: recipeStepNodes[8])
        ].compactMap { $0 }

        let recipeStepGraph = RecipeStepGraph()
        for edge in recipeStepEdges {
            try recipeStepGraph.addEdge(edge)
        }

        guard let graph = SessionRecipeStepGraph(graph: recipeStepGraph) else {
            XCTFail("Graph initialisation failed")
            return
        }

        let initiallyCompletedNode = graph.nodes.randomElement()
        initiallyCompletedNode?.isCompleted = true

        graph.resetSteps()

        for node in graph.nodes {
            XCTAssertFalse(node.isCompleted)

            if node.label == recipeSteps[0] {
                XCTAssertTrue(node.isCompletable)
            } else {
                XCTAssertFalse(node.isCompletable)
            }
        }
    }

    func testCompleteStep() throws {
        let recipeSteps = [
            try RecipeStep(content: """
                Boil a large, salted pot of water for the pasta and cook it al dente according to package directions.
            """),
            try RecipeStep(content: """
                Meanwhile, add the butter and oil to a skillet over medium-high heat.
            """),
            try RecipeStep(content: """
                Add the mushrooms and garlic to the pan and sauté for about 5 minutes, stirring often,
                until the mushrooms release most of their water and it's cooked off.
            """),
            try RecipeStep(content: """
                In the meantime, mix the wine, Italian seasoning, lemon juice, flour, and Dijon mustard together.
            """),
            try RecipeStep(content: """
                Once done, take the mushrooms out of the pan and set aside.
            """),
            try RecipeStep(content: """
                Add the mix to the pan. Stir until it becomes a smooth paste.
            """),
            try RecipeStep(content: """
                Stir in the cream and let it simmer for a couple of minutes.
            """),
            try RecipeStep(content: """
                Add the mushrooms back into the pan.
                Reduce the heat and cook for a few more minutes until the sauce has thickened up a bit.
                Season sauce with salt & pepper as needed.
            """),
            try RecipeStep(content: """
                Drain the pasta and toss it with the sauce along with the parsley and parmesan if using.
            """)
        ]
        let nodes = recipeSteps.map { SessionRecipeStepNode(RecipeStepNode($0)) }

        let edges = [
            Edge<SessionRecipeStepNode>(source: nodes[0], destination: nodes[1]),
            Edge<SessionRecipeStepNode>(source: nodes[0], destination: nodes[8]),
            Edge<SessionRecipeStepNode>(source: nodes[1], destination: nodes[2]),
            Edge<SessionRecipeStepNode>(source: nodes[2], destination: nodes[3]),
            Edge<SessionRecipeStepNode>(source: nodes[2], destination: nodes[4]),
            Edge<SessionRecipeStepNode>(source: nodes[3], destination: nodes[5]),
            Edge<SessionRecipeStepNode>(source: nodes[4], destination: nodes[5]),
            Edge<SessionRecipeStepNode>(source: nodes[5], destination: nodes[6]),
            Edge<SessionRecipeStepNode>(source: nodes[6], destination: nodes[7]),
            Edge<SessionRecipeStepNode>(source: nodes[7], destination: nodes[8])
        ].compactMap { $0 }

        let graph = SessionRecipeStepGraph()

        for node in nodes {
            graph.addNode(node)
        }

        for edge in edges {
            try graph.addEdge(edge)
        }

        graph.resetSteps()

        XCTAssertTrue(nodes[0].isCompletable)

        graph.completeStep(nodes[0])

        XCTAssertTrue(nodes[0].isCompleted)
        XCTAssertTrue(nodes[1].isCompletable)
        XCTAssertFalse(nodes[8].isCompletable)

        graph.completeStep(nodes[1])
        graph.completeStep(nodes[2])

        XCTAssertTrue(nodes[3].isCompletable)
        XCTAssertTrue(nodes[4].isCompletable)

        graph.completeStep(nodes[3])

        XCTAssertFalse(nodes[5].isCompletable)

        graph.completeStep(nodes[4])

        XCTAssertTrue(nodes[5].isCompletable)

        graph.completeStep(nodes[5])
        graph.completeStep(nodes[6])
        graph.completeStep(nodes[7])

        XCTAssertTrue(nodes[8].isCompletable)
    }
}
