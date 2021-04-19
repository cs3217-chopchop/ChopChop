import SwiftUI

/**
 Represents a view displaying that an entity is in the process of being loaded.
 */
struct ProgressView: View {
    @Binding private var isShow: Bool

    init(isShow: Binding<Bool>) {
        self._isShow = isShow
    }

    var body: some View {
        ActivityIndicator(isShow: self.$isShow)
    }
}

struct ActivityIndicator: UIViewRepresentable {
    @Binding var isShow: Bool

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.contentScaleFactor = 5
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }

    func updateUIView(_ uiView: UIActivityIndicatorView,
                      context: Context) {
        if self.isShow {
            uiView.startAnimating()
        } else {
            uiView.stopAnimating()
        }
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView(isShow: .constant(true))
    }
}
