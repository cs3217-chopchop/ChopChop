import UIKit

/**
 A class that manages the persistence of images into local storage.
 Reference: https://gist.github.com/TheCodedSelf/7ff3a4fb64f8f6131925fa3e6e21efbe
 */
struct ImageStore {
    static let fileManager = FileManager.default

    /**
     Deletes the image with the given name in the folder with the given folder name from local storage.
     If such an image or folder does not exist, do nothing.
     */
    static func delete(imageNamed name: String, inFolderNamed folderName: String = "") {
        guard let imagePath = ImageStore.getFilePath(for: name, folderName: folderName) else {
            return
        }

        try? ImageStore.fileManager.removeItem(at: imagePath)
    }

    /**
     Deletes all images with names in the given array of names from the folder with the given folder name.
     */
    static func delete(imagesNamed names: [String], inFolderNamed folderName: String = "") {
        for name in names {
            delete(imageNamed: name, inFolderNamed: folderName)
        }
    }

    /**
     Deletes all images in the folder with the given folder name.
     If such a folder does not exist, do nothing.
     */
    static func deleteAll(inFolderNamed folderName: String = "") {
        guard let folderPath = try? ImageStore.fileManager.url(for: .documentDirectory,
                                                               in: .userDomainMask,
                                                               appropriateFor: nil,
                                                               create: true)
                .appendingPathComponent("Images")
                .appendingPathComponent(folderName) else {
            return
        }

        guard let imagePaths = try? ImageStore.fileManager.contentsOfDirectory(at: folderPath,
                                                                               includingPropertiesForKeys: nil) else {
            return
        }

        for imagePath in imagePaths {
            try? ImageStore.fileManager.removeItem(at: imagePath)
        }
    }

    /**
     Returns the image with the given name from the folder with the given folder name,
     or `nil` if such an image does not exist.
     */
    static func fetch(imageNamed name: String, inFolderNamed folderName: String = "") -> UIImage? {
        guard let imagePath = ImageStore.getFilePath(for: name, folderName: folderName) else {
            return nil
        }

        let image = UIImage(contentsOfFile: imagePath.path)
        return image
    }

    /**
     Saves the given image with the given name into the folder with the given folder name.

     - Throws:
        - `ImageStoreError.imageCreationFailure`
            if the given image could not be converted into PNG data.
        - `ImageStoreError.pathCreationFailure`
            if the path could not be created with the given image name and folder name.
     */
    static func save(image: UIImage, name: String, inFolderNamed folderName: String = "") throws {
        guard let imageData = image.png() else {
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

        guard let directory = try? ImageStore.fileManager.url(for: .documentDirectory,
                                                              in: .userDomainMask,
                                                              appropriateFor: nil,
                                                              create: true) else {
            return nil
        }

        let folderURL = directory
            .appendingPathComponent("Images")
            .appendingPathComponent(folderName)

        do {
            try ImageStore.fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        } catch {
            return nil
        }

        return folderURL.appendingPathComponent("\(imageName).\(fileExtension)")
    }
}

enum ImageStoreError: Error {
    case imageCreationFailure
    case pathCreationFailure
}

// MARK: - Orientate Image
extension UIImage {
    /**
     Converts the given image into PNG data with the correct orientation..
     */
    func png(isOpaque: Bool = true) -> Data? {
        flattened(isOpaque: isOpaque).pngData()
    }

    private func flattened(isOpaque: Bool = true) -> UIImage {
        if imageOrientation == .up {
            return self
        }

        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in draw(at: .zero) }
    }
}
