import UIKit
import SwiftUI

// https://www.appcoda.com/swiftui-camera-photo-library/
struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType = .photoLibrary

    @Binding var selectedImage: UIImage
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator

        return imagePicker
    }

    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: UIViewControllerRepresentableContext<ImagePicker>) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

extension ImagePicker {
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            defer {
                parent.presentationMode.wrappedValue.dismiss()
            }

            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }
        }
    }
}

extension UIImage.Orientation {
    var description: String {
        switch self {
        case .up:
            return "up"
        case .down:
            return "down"
        case .left:
            return "left"
        case .right:
            return "right"
        case .upMirrored:
            return "upM"
        case .downMirrored:
            return "downM"
        case .leftMirrored:
            return "leftM"
        case .rightMirrored:
            return "rightM"
        }
    }
}
