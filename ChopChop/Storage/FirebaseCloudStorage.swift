import FirebaseStorage
import UIKit

struct FirebaseCloudStorage {
    let storageRef = Storage.storage().reference()

    func uploadImage(image: UIImage, name: String, onComplete: @escaping (_ url: String?) -> Void) {
        let uploadRef = storageRef.child("images/\(name).png")
        guard let uploadData = image.pngData() else {
            return
        }
        print("before put")
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        uploadRef.putData(uploadData, metadata: metaData) { _, error in
            if error != nil {
                onComplete(nil)
            } else {
                uploadRef.downloadURL { url, _ in
                    let downloadURL = url?.absoluteString
                    onComplete(downloadURL)
                }
            }
        }
    }
}
