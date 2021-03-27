import XCTest

@testable import ChopChop

class DirectedAcyclicGraphTests: XCTestCase {
    var dag: DirectedAcyclicGraph<Int>!

    override func setUpWithError() throws {
        try super.setUpWithError()

        dag = DirectedAcyclicGraph<Int>()
    }

    override func tearDownWithError() throws {
        dag = nil

        try super.tearDownWithError()
    }

    func makeTestDAG() throws -> DirectedAcyclicGraph<Int> {
        try makeDAGWithEdges(
            Edge(source: Node(1), destination: Node(2)),
            Edge(source: Node(1), destination: Node(6)),
            Edge(source: Node(1), destination: Node(7)),
            Edge(source: Node(2), destination: Node(3)),
            Edge(source: Node(2), destination: Node(5)),
            Edge(source: Node(3), destination: Node(7)),
            Edge(source: Node(4), destination: Node(3)),
            Edge(source: Node(5), destination: Node(4)),
            Edge(source: Node(6), destination: Node(4))
        )
    }

    func makeDAGWithEdges(_ edges: Edge<Int>?...) throws -> DirectedAcyclicGraph<Int> {
        let dag = DirectedAcyclicGraph<Int>()

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
        let existingEdge = try XCTUnwrap(Edge(source: Node(1), destination: Node(2), weight: 1.0))

        try dag.addEdge(existingEdge)

        let testEdge = try XCTUnwrap(Edge(source: Node(1), destination: Node(2), weight: 2.0))

        XCTAssertTrue(dag.containsEdge(testEdge), "Graph should contain edge with same nodes but different weight")
    }
}

// MARK: - addEdge
extension DirectedAcyclicGraphTests {
    func testAddEdge_validEdge_success() throws {
        let validEdge1 = try XCTUnwrap(Edge(source: Node(1), destination: Node(2)))
        let validEdge2 = try XCTUnwrap(Edge(source: Node(2), destination: Node(3)))
        let validEdge3 = try XCTUnwrap(Edge(source: Node(1), destination: Node(3)))

        XCTAssertNoThrow(try dag.addEdge(validEdge1))
        XCTAssertNoThrow(try dag.addEdge(validEdge2))
        XCTAssertNoThrow(try dag.addEdge(validEdge3))
    }

    func testAddEdge_existingEdge_throwsError() throws {
        let existingEdge = try XCTUnwrap(Edge(source: Node(1), destination: Node(2), weight: 1.0))

        try dag.addEdge(existingEdge)

        XCTAssertThrowsError(try dag.addEdge(existingEdge))

        let sameNodesEdge = try XCTUnwrap(Edge(source: Node(1), destination: Node(2), weight: 2.0))

        XCTAssertThrowsError(try dag.addEdge(sameNodesEdge))
    }

    func testAddEdge_formsCycle_throwsError() throws {
        let existingEdge1 = try XCTUnwrap(Edge(source: Node(1), destination: Node(2)))
        let existingEdge2 = try XCTUnwrap(Edge(source: Node(2), destination: Node(3)))

        try dag.addEdge(existingEdge1)
        try dag.addEdge(existingEdge2)

        let invalidEdge1 = try XCTUnwrap(Edge(source: Node(2), destination: Node(1)))
        let invalidEdge2 = try XCTUnwrap(Edge(source: Node(3), destination: Node(1)))

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
                Node(1),
                Node(2),
                Node(5),
                Node(6),
                Node(4),
                Node(3),
                Node(7)
            ],
            [
                Node(1),
                Node(2),
                Node(6),
                Node(5),
                Node(4),
                Node(3),
                Node(7)
            ],
            [
                Node(1),
                Node(6),
                Node(2),
                Node(5),
                Node(4),
                Node(3),
                Node(7)
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
            [Node(1)],
            [Node(2), Node(6)],
            [Node(5)],
            [Node(4)],
            [Node(3)],
            [Node(7)]
        ]

        let result = dag.getNodeLayers()

        XCTAssertEqual(result, expectedResult, "Node layers should be computed correctly")
    }
}
