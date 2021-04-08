import Foundation

class LayeredDAGDrawer<N: DrawableNode> {
    typealias E = Edge<DrawerNode>
    typealias Layer = [DrawerNode]

    let graph: DirectedAcyclicGraph<DrawerNode>
    let nodes: [N]
    private var layers: [Layer]

    init?(_ dag: DirectedAcyclicGraph<N>) {
        self.nodes = dag.nodes
        var nodeToId: [N: Int] = [:]

        for i in 0..<nodes.count {
            nodeToId[nodes[i]] = i
        }

        let drawerNodes = nodeToId.map { DrawerNode(label: $1) }
        let drawerEdges = dag.edges.compactMap { edge -> E? in
            guard let sourceId = nodeToId[edge.source],
                  let destinationId = nodeToId[edge.destination] else {
                return nil
            }

            let sourceDrawerNode = DrawerNode(label: sourceId)
            let destinationDrawerNode = DrawerNode(label: destinationId)
            return E(source: sourceDrawerNode, destination: destinationDrawerNode)
        }

        guard drawerEdges.count == dag.edges.count else {
            return nil
        }

        do {
            self.graph = try DirectedAcyclicGraph<DrawerNode>(nodes: drawerNodes, edges: drawerEdges)
        } catch {
            return nil
        }

        self.layers = LayeredDAGDrawer.getDrawerNodeLayers(from: graph)
    }

    private static func getDrawerNodeLayers(from graph: DirectedAcyclicGraph<DrawerNode>) -> [Layer] {
        var drawerNodeLayers: [Layer] = []

        var currentNodes = Set(graph.nodes)
        var currentEdges = Set(graph.edges)
        var currentLayer = getNodesWithoutIncomingEdges(nodes: currentNodes, edges: currentEdges)

        while !currentLayer.isEmpty {
            drawerNodeLayers.append(Array(currentLayer))
            currentNodes.subtract(currentLayer)
            currentEdges = currentEdges.filter { !currentLayer.contains($0.source) }
            currentLayer = getNodesWithoutIncomingEdges(nodes: currentNodes, edges: currentEdges)
        }

        return drawerNodeLayers
    }

    private static func getNodesWithoutIncomingEdges(nodes: Set<DrawerNode>, edges: Set<E>) -> Set<DrawerNode> {
        let destinationNodes = Set(edges.map { $0.destination })
        return nodes.filter { !destinationNodes.contains($0) }
    }

    func calculateNodePositions(horizontalDistance: Float, verticalDistance: Float) {
        insertVirtualNodesAndEdges()

        var optimalLayers = layers

        for i in 0..<24 {
            reorderLayersByMedian(iteration: i)
            reduceCrossingsWithTransposition()
            if countCrossings(layers: layers) < countCrossings(layers: optimalLayers) {
                optimalLayers = layers
            }
        }

        self.layers = optimalLayers

        positionDrawerNodes(horizontalDistance: horizontalDistance, verticalDistance: verticalDistance)
        
    }

    // MARK: - Node Ordering: Virtual Nodes
    private func insertVirtualNodesAndEdges() {
        var virtualNodeId = -1
        for i in 0..<layers.count - 1 {
            let currentLayer = layers[i]
            var nextLayer = layers[i + 1]

            for currentNode in currentLayer {
                let longOutgoingEdges = graph.edges
                    .filter { $0.source == currentNode }
                    .filter { getNumberOfLayers(between: $0.destination, and: currentNode) > 1}

                for edge in longOutgoingEdges {
                    let virtualNode = DrawerNode(label: virtualNodeId)
                    virtualNodeId -= 1

                    replaceEdgeWithVirtualNodeAndEdges(edge, virtualNode: virtualNode)
                    nextLayer.append(virtualNode)
                }
            }

            layers[i + 1] = nextLayer
        }
    }

    private func replaceEdgeWithVirtualNodeAndEdges(_ edge: E, virtualNode: DrawerNode) {
        guard let upperEdge = E(source: edge.source, destination: virtualNode),
              let lowerEdge = E(source: virtualNode, destination: edge.destination) else {
            return
        }

        graph.addNode(virtualNode)
        graph.removeEdge(edge)

        do {
            try graph.addEdge(upperEdge)
            try graph.addEdge(lowerEdge)
        } catch {
            return
        }
    }

    private func getNumberOfLayers(between first: DrawerNode, and second: DrawerNode) -> Int {
        guard let firstLayerNumber = getLayerNumber(of: first),
              let secondLayerNumber = getLayerNumber(of: second) else {
            return -1
        }

        return abs(firstLayerNumber - secondLayerNumber)
    }

    private func getLayerNumber(of node: DrawerNode) -> Int? {
        layers.firstIndex(where: { layer in
            layer.contains(node)
        })
    }

    // MARK: - Node Ordering: Median
    private func reorderLayersByMedian(iteration: Int) {
        if iteration % 2 == 0 {
            for layerNumber in 1..<layers.count {
                let medians = layers[layerNumber].compactMap { node in
                    getMedianFromPreviousLayer(of: node, layerNumber: layerNumber)
                }
                let sortedLayer = sort(layer: layers[layerNumber], with: medians)
                layers[layerNumber] = sortedLayer
            }
        } else {
            for layerNumber in stride(from: layers.count - 2, through: 0, by: -1) {
                let medians = layers[layerNumber].compactMap { node in
                    getMedianFromNextLayer(of: node, layerNumber: layerNumber)
                }
                let sortedLayer = sort(layer: layers[layerNumber], with: medians)
                layers[layerNumber] = sortedLayer
            }
        }
    }

    private func sort(layer: Layer, with medians: [Double]) -> Layer {
        guard layer.count == medians.count else {
            return layer
        }

        let sortedLayer = layer.enumerated()
            .map { index, node in
                (median: medians[index], node: node)
            }
            .sorted { $0.median <= $1.median }
            .map { $0.node }

        return sortedLayer
    }

    private func getMedianFromPreviousLayer(of targetNode: DrawerNode, layerNumber: Int) -> Double? {
        guard 1..<layers.count ~= layerNumber else {
            return nil
        }

        let previousLayer = layers[layerNumber - 1]
        let parentNodeIds = previousLayer.enumerated().compactMap { index, node -> Int? in
            guard graph.getNodesAdjacent(to: node).contains(targetNode) else {
                return nil
            }

            return index
        }

        return getMedianOfSortedArray(parentNodeIds)
    }

    private func getMedianFromNextLayer(of targetNode: DrawerNode, layerNumber: Int) -> Double? {
        guard 0..<layers.count - 1 ~= layerNumber else {
            return nil
        }

        let nextLayer = layers[layerNumber + 1]
        let childrenNodeIds = graph.getNodesAdjacent(to: targetNode).compactMap { node in
            nextLayer.firstIndex(of: node)
        }

        return getMedianOfSortedArray(childrenNodeIds.sorted())
    }

    private func getMedianOfSortedArray(_ array: [Int]) -> Double {
        if array.count % 2 == 0 {
            let leftMid = array[array.count / 2 - 1]
            let rightMid = array[array.count / 2]
            return Double(leftMid + rightMid) / 2
        } else {
            return Double(array[array.count / 2])
        }
    }

    // MARK: - Node Ordering: Crossings
    private func countCrossings(layers: [Layer]) -> Int {
        Array(0..<layers.count - 1)
            .map { countCrossings(upperLayerNumber: $0) }
            .reduce(0, +)
    }

    private func countCrossings(layerNumber: Int) -> Int {
        if layerNumber == 0 {
            return countCrossings(upperLayerNumber: layerNumber)
        } else if layerNumber == layers.count - 1 {
            return countCrossings(upperLayerNumber: layerNumber - 1)
        } else {
            return countCrossings(upperLayerNumber: layerNumber - 1) + countCrossings(upperLayerNumber: layerNumber)
        }
    }

    private func countCrossings(upperLayerNumber: Int) -> Int {
        var crossingCount = 0

        guard 0..<layers.count - 1 ~= upperLayerNumber else {
            return crossingCount
        }

        let edges = layers[upperLayerNumber]
            .compactMap { graph.getEdgesFromNode($0) }
            .reduce(into: [], +=)

        for i in 0..<edges.count {
            for j in i..<edges.count where hasCrossingBetween(edges[i], and: edges[j], upperLayerNumber: upperLayerNumber) {
                crossingCount += 1
            }
        }

        return crossingCount
    }

    private func hasCrossingBetween(_ firstEdge: E, and secondEdge: E, upperLayerNumber: Int) -> Bool {
        guard let firstEdgeSourceIndex = getIndex(of: firstEdge.source, layerNumber: upperLayerNumber),
            let firstEdgeDestinationIndex = getIndex(of: firstEdge.destination, layerNumber: upperLayerNumber + 1),
            let secondEdgeSourceIndex = getIndex(of: secondEdge.source, layerNumber: upperLayerNumber),
            let secondEdgeDestinationIndex = getIndex(of: secondEdge.destination, layerNumber: upperLayerNumber + 1) else {
            return false
        }

        return (firstEdgeSourceIndex < secondEdgeSourceIndex && firstEdgeDestinationIndex > secondEdgeDestinationIndex)
            || (firstEdgeSourceIndex > secondEdgeSourceIndex && firstEdgeDestinationIndex < secondEdgeDestinationIndex)
    }

    private func getIndex(of targetNode: DrawerNode, layerNumber: Int) -> Int? {
        guard 0..<layers.count ~= layerNumber else {
            return nil
        }

        return layers[layerNumber].firstIndex(of: targetNode)
    }

    // MARK: - Node Ordering: Transpose
    private func reduceCrossingsWithTransposition() {
        var hasImproved = true

        while hasImproved {
            hasImproved = false

            for layerNumber in 0..<layers.count {
                var currentLayer = layers[layerNumber]

                for i in 0..<currentLayer.count - 1 {
                    let currentCrossings = countCrossings(layerNumber: layerNumber)
                    swap(&currentLayer, firstId: i, secondId: i + 1)
                    layers[layerNumber] = currentLayer
                    let newCrossings = countCrossings(layerNumber: layerNumber)

                    if newCrossings < currentCrossings {
                        hasImproved = true
                    } else {
                        swap(&currentLayer, firstId: i, secondId: i + 1)
                    }
                }
            }
        }
    }

    private func swap(_ layer: inout Layer, firstId: Int, secondId: Int) {
        guard 0..<layer.count ~= firstId && 0..<layer.count ~= secondId else {
            return
        }

        let temp = layer[firstId]
        layer[firstId] = layer[secondId]
        layer[secondId] = temp
    }

    // MARK: - Node Positioning
    private func positionDrawerNodes(horizontalDistance: Float, verticalDistance: Float) {
        for (layerIndex, layer) in layers.enumerated() {
            for (nodeIndex, node) in layer.enumerated() {
                node.position = Point(
                    x: Float(nodeIndex) * horizontalDistance,
                    y: Float(layerIndex) * verticalDistance)
            }
        }
    }
}

// MARK: - DrawerNode
extension LayeredDAGDrawer {
    class DrawerNode: DrawableNode {
        let id = UUID()
        let label: Int
        var position: Point?

        init(label: Int) {
            self.label = label
        }

        static func == (lhs: DrawerNode, rhs: DrawerNode) -> Bool {
            lhs.label == rhs.label
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(label)
        }
    }
}
