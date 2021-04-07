import Foundation

class LayeredDAGDrawer<N: Node> {
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

    func getNodeLayers() -> [[N]] {
        insertVirtualNodesAndEdges()
        
    }

    // MARK: - Virtual Nodes
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

    // MARK: - Node Ordering
    private func getMedian(of node: DrawerNode, layerNumber: Int) -> Int {
        guard let previousLayer = layers[layerNumber - 1] else {
            return -1
        }

        
    }
}

// MARK: - DrawerNode
extension LayeredDAGDrawer {
    struct DrawerNode: Node {
        let id = UUID()
        let label: Int

        static func == (lhs: DrawerNode, rhs: DrawerNode) -> Bool {
            lhs.label == rhs.label
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(label)
        }
    }
}
