import FirebaseStorage
import UIKit
import Combine

struct FirebaseCloudStorage {
    let storageRef = Storage.storage().reference()
    static let imageMaxSize: Int64 = 1_000 * 1_024 * 1_024
    private let cache: FirebaseCache

    init(cache: FirebaseCache) {
        self.cache = cache
    }

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

    func downloadImage(name: String, onComplete: @escaping (_ data: Data?) -> Void) {
        let downloadRef = storageRef.child("images/\(name).png")
        downloadRef.getData(maxSize: FirebaseCloudStorage.imageMaxSize) { data, error in
            if error != nil {
                onComplete(nil)
            } else {
                onComplete(data)
            }
        }
    }

    func fetchImage(name: String, completion: @escaping (Data?) -> Void) {
        let fetchRef = storageRef.child("images/\(name).png")
        fetchRef.getData(maxSize: FirebaseCloudStorage.imageMaxSize) {
            data, error in
                if error != nil {
                    completion(nil)
                } else {
                    completion(data)
                }
        }
    }

    func deleteImage(name: String) {
        let imageRef = storageRef.child("images/\(name).png")
        imageRef.delete()
    }
}
