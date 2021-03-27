class SessionRecipeStepNode: Node {
    var label: SessionRecipeStep
    var isCompletable: Bool = false
    var isCompleted: Bool = false

    init(_ label: SessionRecipeStep) {
        self.label = label
    }
}

extension SessionRecipeStepNode: Hashable {
    static func == (lhs: SessionRecipeStepNode, rhs: SessionRecipeStepNode) -> Bool {
        lhs.label == rhs.label
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(label)
    }
}
