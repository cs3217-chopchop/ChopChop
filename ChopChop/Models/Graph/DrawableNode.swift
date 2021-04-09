import CoreGraphics

protocol DrawableNode: Node {
    var position: CGPoint? { get set }
}
