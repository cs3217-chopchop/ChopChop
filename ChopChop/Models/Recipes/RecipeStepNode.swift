struct RecipeStepNode: Node {
    var label: RecipeStep

    init(_ label: RecipeStep) {
        self.label = label
    }
}
