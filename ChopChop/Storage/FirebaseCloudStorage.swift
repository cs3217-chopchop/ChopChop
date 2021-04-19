import FirebaseStorage
import UIKit
import Combine

struct FirebaseCloudStorage {
    let storageRef = Storage.storage().reference()
    static let imageMaxSize: Int64 = 1_000 * 1_024 * 1_024

    func uploadImage(image: UIImage, name: String) {
        let uploadRef = storageRef.child("images/\(name).png")
        guard let uploadData = image.pngData() else {
            return
        }
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        uploadRef.putData(uploadData, metadata: metaData) { _, error in
            if error != nil {
                debugPrint("error")
            } else {
                return
            }
        }
    }

    func fetchImage(name: String, completion: @escaping (Data?, Error?) -> Void) {
        let downloadRef = storageRef.child("images/\(name).png")
        downloadRef.getData(maxSize: FirebaseCloudStorage.imageMaxSize) { data, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            completion(data, nil)
        }
    }

    func deleteImage(name: String) {
        let imageRef = storageRef.child("images/\(name).png")
        imageRef.delete()
    }
}
