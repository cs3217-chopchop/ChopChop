import XCTest

@testable import ChopChop

class DirectedAcyclicGraphTests: XCTestCase {
    struct IntNode: Node {
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
        try makeDAGWithEdges(
            Edge(source: IntNode(1), destination: IntNode(2)),
            Edge(source: IntNode(1), destination: IntNode(6)),
            Edge(source: IntNode(1), destination: IntNode(7)),
            Edge(source: IntNode(2), destination: IntNode(3)),
            Edge(source: IntNode(2), destination: IntNode(5)),
            Edge(source: IntNode(3), destination: IntNode(7)),
            Edge(source: IntNode(4), destination: IntNode(3)),
            Edge(source: IntNode(5), destination: IntNode(4)),
            Edge(source: IntNode(6), destination: IntNode(4))
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
        let existingEdge = try XCTUnwrap(Edge(source: IntNode(1), destination: IntNode(2), weight: 1.0))

        try dag.addEdge(existingEdge)

        let testEdge = try XCTUnwrap(Edge(source: IntNode(1), destination: IntNode(2), weight: 2.0))

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
        let existingEdge = try XCTUnwrap(Edge(source: IntNode(1), destination: IntNode(2), weight: 1.0))

        try dag.addEdge(existingEdge)

        XCTAssertThrowsError(try dag.addEdge(existingEdge))

        let sameNodesEdge = try XCTUnwrap(Edge(source: IntNode(1), destination: IntNode(2), weight: 2.0))

        XCTAssertThrowsError(try dag.addEdge(sameNodesEdge))
    }

    func testAddEdge_formsCycle_throwsError() throws {
        let existingEdge1 = try XCTUnwrap(Edge(source: IntNode(1), destination: IntNode(2)))
        let existingEdge2 = try XCTUnwrap(Edge(source: IntNode(2), destination: IntNode(3)))

        try dag.addEdge(existingEdge1)
        try dag.addEdge(existingEdge2)

        let invalidEdge1 = try XCTUnwrap(Edge(source: IntNode(2), destination: IntNode(1)))
        let invalidEdge2 = try XCTUnwrap(Edge(source: IntNode(3), destination: IntNode(1)))

        XCTAssertThrowsError(try dag.addEdge(invalidEdge1))
        XCTAssertThrowsError(try dag.addEdge(invalidEdge2))
    }
}

// MARK: - Topological Sort
extension DirectedAcyclicGraphTests {
    func testGetTopologicallySortedNodes() throws {
        dag = try makeTestDAG()

        let expectedResults = [
            [
                IntNode(1),
                IntNode(2),
                IntNode(5),
                IntNode(6),
                IntNode(4),
                IntNode(3),
                IntNode(7)
            ],
            [
                IntNode(1),
                IntNode(2),
                IntNode(6),
                IntNode(5),
                IntNode(4),
                IntNode(3),
                IntNode(7)
            ],
            [
                IntNode(1),
                IntNode(6),
                IntNode(2),
                IntNode(5),
                IntNode(4),
                IntNode(3),
                IntNode(7)
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

        let expectedResult = [
            [IntNode(1)],
            [IntNode(2), IntNode(6)],
            [IntNode(5)],
            [IntNode(4)],
            [IntNode(3)],
            [IntNode(7)]
        ]

        let result = dag.getNodeLayers()

        XCTAssertEqual(result, expectedResult, "IntNode layers should be computed correctly")
    }
}
