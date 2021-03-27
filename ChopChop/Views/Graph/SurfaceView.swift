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
        GeometryReader { _ in
            ZStack {
                Rectangle()
                    .fill(Color.yellow)
                GraphView(selection: selection, graph: viewModel.graph)
                    .offset(x: portalPosition.x + dragOffset.width,
                            y: portalPosition.y + dragOffset.height)
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        processDragChange(value)
                    }
                    .onEnded { value in
                        processDragEnd(value)
                    }
            )
        }
    }
}

extension SurfaceView {
    func processDragChange(_ value: DragGesture.Value) {
        isDraggingGraph = true
        dragOffset = value.translation
    }

    func processDragEnd(_ value: DragGesture.Value) {
        isDraggingGraph = false
        dragOffset = .zero

        portalPosition = CGPoint(x: portalPosition.x + value.translation.width,
                                 y: portalPosition.y + value.translation.height)
    }
}

// struct SurfaceView_Previews: PreviewProvider {
//    static var previews: some View {
//        SurfaceView()
//    }
// }
