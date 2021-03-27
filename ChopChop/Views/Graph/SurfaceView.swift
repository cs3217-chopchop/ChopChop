import SwiftUI

struct SurfaceView: View {
    @ObservedObject var viewModel: SurfaceViewModel
    @ObservedObject var selection = SelectionHandler()

    @State var portalPosition = CGPoint.zero
    @State var dragOffset = CGSize.zero
    @State var isDragging = false
    @State var isDraggingGraph = false

    @State var zoomScale: CGFloat = 1.0
    @State var initialZoomScale: CGFloat?
    @State var initialPortalPosition: CGPoint?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(Color.yellow)
                GraphView(selection: selection, graph: viewModel.graph)
                    .offset(x: portalPosition.x + dragOffset.width,
                            y: portalPosition.y + dragOffset.height)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        processDragChange(value, containerSize: geometry.size)
                    }
                    .onEnded { value in
                        processDragEnd(value)
                    }
            )
        }
    }
}

extension SurfaceView {
    func hitTest(point: CGPoint, parent: CGSize) -> Node? {
        for node in viewModel.graph.vertices {
            let endPoint = CGPoint(x: node.position.x + portalPosition.x
                                    - (selection.isNodeSelected(node) ? NodeView.expandedSize.width : NodeView.initialSize.width) / 2,
                                   y: node.position.y + portalPosition.y
                                    - (selection.isNodeSelected(node) ? NodeView.expandedSize.height : NodeView.initialSize.height) / 2)
            let rect = CGRect(origin: endPoint,
                              size: selection.isNodeSelected(node) ? NodeView.expandedSize : NodeView.initialSize)

            if rect.contains(point) {
                print("gotcha")
                return node
            }
        }

        return nil
    }

    func processDragChange(_ value: DragGesture.Value, containerSize: CGSize) {
        if let node = hitTest(point: value.startLocation, parent: containerSize) {
            print(node.text)
            selection.toggleNode(node)
        } else {
            isDraggingGraph = true
            dragOffset = value.translation
        }
    }

    func processDragEnd(_ value: DragGesture.Value) {
        if isDraggingGraph {
            isDraggingGraph = false
            dragOffset = .zero

            portalPosition = CGPoint(x: portalPosition.x + value.translation.width,
                                     y: portalPosition.y + value.translation.height)
        }
    }
}

// struct SurfaceView_Previews: PreviewProvider {
//    static var previews: some View {
//        SurfaceView()
//    }
// }
