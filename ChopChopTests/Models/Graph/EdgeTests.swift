// Took reference from AY2021S2 CS3217 Problem Set 1

import XCTest
@testable import ChopChop

class EdgeTests: XCTestCase {
    struct TestNode: Node {
        let id = UUID()
        var label: String

        init(_ label: String) {
            self.label = label
        }
    }

    func testConstruct() {
        let node1 = TestNode("A")
        let node2 = TestNode("B")
        let edge = Edge(source: node1, destination: node2, weight: 2.0)

        XCTAssertEqual(edge?.source, node1, "Edge's source is not constructed properly")
        XCTAssertEqual(edge?.destination, node2, "Edge's destination is not constructed properly")
        XCTAssertEqual(edge?.weight, 2.0, "Edge's weight is not constructed properly")
    }

    func testRepInvariant_nonNegativeWeight() {
        let node1 = TestNode("A")
        let node2 = TestNode("B")
        XCTAssertNil(Edge(source: node1, destination: node2, weight: -3.0),
                     "Edges with negative weight should not be constructed")
    }

    func testReversed_swapSourceAndDestinationWithSameWeight() {
        let node1 = TestNode("A")
        let node2 = TestNode("B")
        let edge = Edge(source: node1, destination: node2, weight: 3.0)
        let reversedEdge = edge?.reversed()

        XCTAssertEqual(reversedEdge?.source, node2, "Reversed edge's source is not correct")
        XCTAssertEqual(reversedEdge?.destination, node1, "Reversed edges's destination is not correct")
        XCTAssertEqual(reversedEdge?.weight, 3.0, "Reversed edges's weight is not correct")
    }

    func testReversed_twiceReversedEdge_sameEdge() {
        let node1 = TestNode("A")
        let node2 = TestNode("B")
        let edge = Edge(source: node1, destination: node2, weight: 3.0)
        let twiceReversedEdge = edge?.reversed().reversed()

        XCTAssertEqual(twiceReversedEdge, edge, "Twiced-reversed edge should be same as the original edge")
    }

    func testEqual_sameSourceSameDestinationSameWeight_isEqual() {
        let node1 = TestNode("A")
        let node2 = TestNode("B")
        let edge1 = Edge(source: node1, destination: node2, weight: 5.0)
        let edge2 = Edge(source: node1, destination: node2, weight: 5.0)

        XCTAssertEqual(edge1, edge2, "Edges with same source, destination and weight should be equal")
    }

    func testEqual_differentWeight_isNotEqual() {
        let node1 = TestNode("A")
        let node2 = TestNode("B")
        let edge1 = Edge(source: node1, destination: node2, weight: 5.0)
        let edge2 = Edge(source: node1, destination: node2, weight: 10.0)

        XCTAssertNotEqual(edge1, edge2, "Edges with different weights should not be equal")
    }
}
