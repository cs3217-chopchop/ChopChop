import XCTest

@testable import ChopChop

class DirectedAcyclicGraphTests: XCTestCase {
    struct IntNode: Node {
        let id = UUID()
        var label: Int

        init(_ label: Int) {
            self.label = label
        }
    }

    var dag: DirectedAcyclicGraph<IntNode>!

    override func setUpWithError() throws {
        try super.setUpWithError()

        dag = DirectedAcyclicGraph<IntNode>()
    }

    override func tearDownWithError() throws {
        dag = nil

        try super.tearDownWithError()
    }

    func makeTestDAG() throws -> DirectedAcyclicGraph<IntNode> {
        let nodes = (1...7).map { IntNode($0) }

        return try makeDAGWithEdges(
            Edge(source: nodes[0], destination: nodes[1]),
            Edge(source: nodes[0], destination: nodes[5]),
            Edge(source: nodes[0], destination: nodes[6]),
            Edge(source: nodes[1], destination: nodes[2]),
            Edge(source: nodes[1], destination: nodes[4]),
            Edge(source: nodes[2], destination: nodes[6]),
            Edge(source: nodes[3], destination: nodes[2]),
            Edge(source: nodes[4], destination: nodes[3]),
            Edge(source: nodes[5], destination: nodes[3])
        )
    }

    func makeDAGWithEdges(_ edges: Edge<IntNode>?...) throws -> DirectedAcyclicGraph<IntNode> {
        let dag = DirectedAcyclicGraph<IntNode>()

        for edge in edges {
            if let validEdge = edge {
                try dag.addEdge(validEdge)
            }
        }

        return dag
    }
}

// MARK: - containsEdge
extension DirectedAcyclicGraphTests {
    func testContainsEdge_existingEdgeSameNodesDifferentWeight_returnTrue() throws {
        let nodes = (1...2).map { IntNode($0) }

        let existingEdge = try XCTUnwrap(Edge(source: nodes[0], destination: nodes[1], weight: 1.0))

        try dag.addEdge(existingEdge)

        let testEdge = try XCTUnwrap(Edge(source: nodes[0], destination: nodes[1], weight: 2.0))

        XCTAssertTrue(dag.containsEdge(testEdge), "Graph should contain edge with same nodes but different weight")
    }
}

// MARK: - addEdge
extension DirectedAcyclicGraphTests {
    func testAddEdge_validEdge_success() throws {
        let validEdge1 = try XCTUnwrap(Edge(source: IntNode(1), destination: IntNode(2)))
        let validEdge2 = try XCTUnwrap(Edge(source: IntNode(2), destination: IntNode(3)))
        let validEdge3 = try XCTUnwrap(Edge(source: IntNode(1), destination: IntNode(3)))

        XCTAssertNoThrow(try dag.addEdge(validEdge1))
        XCTAssertNoThrow(try dag.addEdge(validEdge2))
        XCTAssertNoThrow(try dag.addEdge(validEdge3))
    }

    func testAddEdge_existingEdge_throwsError() throws {
        let nodes = (1...2).map { IntNode($0) }

        let existingEdge = try XCTUnwrap(Edge(source: nodes[0], destination: nodes[1], weight: 1.0))

        try dag.addEdge(existingEdge)

        XCTAssertThrowsError(try dag.addEdge(existingEdge))

        let sameNodesEdge = try XCTUnwrap(Edge(source: nodes[0], destination: nodes[1], weight: 2.0))

        XCTAssertThrowsError(try dag.addEdge(sameNodesEdge))
    }

    func testAddEdge_formsCycle_throwsError() throws {
        let nodes = (1...3).map { IntNode($0) }

        let existingEdge1 = try XCTUnwrap(Edge(source: nodes[0], destination: nodes[1]))
        let existingEdge2 = try XCTUnwrap(Edge(source: nodes[1], destination: nodes[2]))

        try dag.addEdge(existingEdge1)
        try dag.addEdge(existingEdge2)

        let invalidEdge1 = try XCTUnwrap(Edge(source: nodes[1], destination: nodes[0]))
        let invalidEdge2 = try XCTUnwrap(Edge(source: nodes[2], destination: nodes[0]))

        XCTAssertThrowsError(try dag.addEdge(invalidEdge1))
        XCTAssertThrowsError(try dag.addEdge(invalidEdge2))
    }
}

// MARK: - Topological Sort
extension DirectedAcyclicGraphTests {
    func testGetTopologicallySortedNodes() throws {
        dag = try makeTestDAG()
        let nodes = dag.nodes.sorted(by: { $0.label < $1.label })

        let expectedResults = [
            [
                nodes[0],
                nodes[1],
                nodes[4],
                nodes[5],
                nodes[3],
                nodes[2],
                nodes[6]
            ],
            [
                nodes[0],
                nodes[1],
                nodes[5],
                nodes[4],
                nodes[3],
                nodes[2],
                nodes[6]
            ],
            [
                nodes[0],
                nodes[5],
                nodes[1],
                nodes[4],
                nodes[3],
                nodes[2],
                nodes[6]
            ]
        ]

        let result = dag.getTopologicallySortedNodes()

        XCTAssertTrue(expectedResults.contains(result), "Result should be one of the correct topological orders")
    }
}

// MARK: - Layers
extension DirectedAcyclicGraphTests {
    func testGetNodeLayers() throws {
        dag = try makeTestDAG()
        let nodes = dag.nodes.sorted(by: { $0.label < $1.label })

        let expectedResults = [
            [
                [nodes[0]],
                [nodes[1], nodes[5]],
                [nodes[4]],
                [nodes[3]],
                [nodes[2]],
                [nodes[6]]
            ],
            [
                [nodes[0]],
                [nodes[5], nodes[1]],
                [nodes[4]],
                [nodes[3]],
                [nodes[2]],
                [nodes[6]]
            ]
        ]

        let result = dag.getNodeLayers()

        XCTAssertTrue(expectedResults.contains(result), "IntNode layers should be computed correctly")
    }
}
