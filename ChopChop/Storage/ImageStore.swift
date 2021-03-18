import UIKit

struct ImageStore {
    static func delete(imageNamed name: String) {
        guard let imagePath = ImageStore.getFilePath(for: name) else {
            return
        }

        try? FileManager.default.removeItem(at: imagePath)
    }

    static func fetch(imageNamed name: String) -> UIImage? {
        guard let imagePath = ImageStore.getFilePath(for: name) else {
            return nil
        }

        return UIImage(contentsOfFile: imagePath.path)
    }

    static func save(image: UIImage, name: String) throws {
        guard let imageData = image.pngData() else {
            throw ImageStoreError.imageCreationFailure
        }

        guard let imagePath = ImageStore.getFilePath(for: name) else {
            throw ImageStoreError.pathCreationFailure
        }

        try imageData.write(to: imagePath)
    }

    private static func getFilePath(
        for imageName: String,
        folderName: String = "",
        fileExtension: String = "png") -> URL? {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return directory?
            .appendingPathComponent("Images")
            .appendingPathComponent(folderName)
            .appendingPathComponent("\(imageName).\(fileExtension)")
    }
}

enum ImageStoreError: Error {
    case imageCreationFailure
    case pathCreationFailure
}
