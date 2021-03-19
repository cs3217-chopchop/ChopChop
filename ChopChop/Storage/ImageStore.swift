import UIKit

// https://gist.github.com/TheCodedSelf/7ff3a4fb64f8f6131925fa3e6e21efbe
struct ImageStore {
    static let fileManager = FileManager.default

    static func delete(imageNamed name: String, inFolderNamed folderName: String = "") {
        guard let imagePath = ImageStore.getFilePath(for: name, folderName: folderName) else {
            return
        }

        try? ImageStore.fileManager.removeItem(at: imagePath)
    }

    static func fetch(imageNamed name: String, inFolderNamed folderName: String = "") -> UIImage? {
        guard let imagePath = ImageStore.getFilePath(for: name, folderName: folderName) else {
            return nil
        }

        return UIImage(contentsOfFile: imagePath.path)
    }

    static func save(image: UIImage, name: String, inFolderNamed folderName: String = "") throws {
        guard let imageData = image.pngData() else {
            throw ImageStoreError.imageCreationFailure
        }

        guard let imagePath = ImageStore.getFilePath(for: name, folderName: folderName) else {
            throw ImageStoreError.pathCreationFailure
        }

        try imageData.write(to: imagePath, options: .atomic)
    }

    private static func getFilePath(
        for imageName: String,
        folderName: String = "",
        fileExtension: String = "png") -> URL? {
        guard !imageName.isEmpty else {
            return nil
        }

        let directory = ImageStore.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first

        guard let folderURL = directory?.appendingPathComponent("Images").appendingPathComponent(folderName) else {
            return nil
        }

        do {
            try ImageStore.fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        } catch {
            return nil
        }

        return folderURL
            .appendingPathComponent("\(imageName).\(fileExtension)")
    }
}

enum ImageStoreError: Error {
    case imageCreationFailure
    case pathCreationFailure
}
