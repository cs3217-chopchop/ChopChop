struct RecipeStepNode: Node {
    var label: RecipeStep

    var id: Int64? {
        label.id
    }

    init(_ label: RecipeStep) {
        self.label = label
    }
}
