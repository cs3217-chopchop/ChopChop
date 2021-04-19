import FirebaseStorage
import UIKit
import Combine

/// Interface with Storage in Firebase
struct FirebaseCloudStorage {
    private let storageRef = Storage.storage().reference()
    private static let imageMaxSize: Int64 = 1_000 * 1_024 * 1_024

    /// Uploads compressed jpg image to Storage
    func uploadImage(image: UIImage, name: String) {
        let uploadRef = getStorageRef(name)
        // compresses image for faster upload
        guard let uploadData = image.jpegData(compressionQuality: 0.3) else {
            return
        }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        uploadRef.putData(uploadData, metadata: metaData) { _, error in
            if error != nil {
                debugPrint("error")
            } else {
                return
            }
        }
    }

    /// Retrieves Image data from Storage of a maximum size
    func fetchImage(name: String, completion: @escaping (Data?, Error?) -> Void) {
        let downloadRef = getStorageRef(name)
        downloadRef.getData(maxSize: FirebaseCloudStorage.imageMaxSize) { data, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            completion(data, nil)
        }
    }

    /// Deletes image from Storage
    func deleteImage(name: String) {
        let imageRef = getStorageRef(name)
        imageRef.delete()
    }

    private func getStorageRef(_ fileName: String) -> StorageReference {
        storageRef.child("images/\(fileName).jpg")
    }
}
