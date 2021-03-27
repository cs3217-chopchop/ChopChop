struct Edge<T: Hashable & Codable>: Hashable, Codable {
    typealias N = Node<T>

    let source: N
    let destination: N
    let weight: Double

    init?(source: N, destination: N) {
        self.init(source: source, destination: destination, weight: 1.0)
    }

    init?(source: N, destination: N, weight: Double) {
        guard weight >= 0 else {
            return nil
        }

        self.source = source
        self.destination = destination
        self.weight = weight
    }

    func reversed() -> Edge<T> {
        guard let reversedEdge = Edge(source: destination, destination: source, weight: weight) else {
            fatalError("Current edge is invalid")
        }

        return reversedEdge
    }
}
